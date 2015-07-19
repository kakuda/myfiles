# ======================================================================
# net/im/yahooj.rb
#
# Net::IM::YahooJ - Yahoo!Messenger日本語版の機能の一部
# ----------------------------------------------------------------------

require "thread"
require "socket"
require "kconv"
require "digest/md5"

module Net
	module IM

# ==============================================================

class YahooJ

	# ======================================================
	# tool
	#
	# exists?(name)
	# online?(name)
	# auth_ok?(id, passwd)
	#
	# get_chat_server
	# get_nick_info(myid, passwd)
	# ------------------------------------------------------

	class << self
		CRLF = "\015\012"

		def http_open(host, path)
			s = TCPSocket.new(host, 80)
			s << "GET #{path} HTTP/1.0#{CRLF}Host: #{host}#{CRLF}#{CRLF}"
			while s.gets
				break if $_ == CRLF
			end
			s
		end

		def html_match?(host, path, pat1, pat2)
			s = http_open(host, path)
			while s.gets
				break if $_ =~ pat1
			end
			s.close
			$_ =~ pat2
		end

		def exists?(name)
			html_match?("profiles.yahoo.co.jp", "/#{name}", "^<!--", "^<!--")
		end

		def online?(name)
			html_match?("opi.yahoo.co.jp", "/online?m=t&u=#{name}", "さんは", "オン")
		end

		def auth_ok?(id, passwd)
			html_match?("edit.my.yahoo.co.jp", "/config/ncclogin?login=#{id}&passwd=#{passwd}", "^(OK|ERROR)", "OK")
		end

		def get_chat_server
			s = http_open("update.messenger.yahoo.co.jp", "/clients.html")
			host_list = [ ]
			while s.gets
				if $_ =~ /^SocketServers=(.*)$/
					host_list += $1.split(";")
				end
			end
			s.close
			#port_list = [ 20, 21, 25, 80, 5050 ]
			port_list = [ 20, 25, 80, 5050 ]
			host = host_list[rand(host_list.length)]
			port = port_list[rand(port_list.length)]
			return host, port
		end

		def get_nick_info(myid, passwd)
			s = http_open("edit.my.yahoo.co.jp", "/config/ncclogin?login=#{id}&passwd=#{passwd}&n=1")
			if s.gets !~ /^OK/
				s.close
				return nil
			end
			friends = ""
			while s.gets
				break if $_ =~ /^BEGIN BUDDYLIST/
			end
			while s.gets
				break if $_ =~ /^END BUDDYLIST/
				friends << $_
			end

			mynicks = ""
			while s.gets
				break if $_ =~ /^BEGIN IDENTITIES/
			end
			while s.gets
				break if $_ =~ /^END IDENTITIES/
				mynicks << $_
			end
			s.close
			return mynicks, friends
		end
	end

	# ======================================================
	# Packet - パケット
	#  event_no     イベント番号
	#  param_list   パラメタリスト
	#  flags        微妙な情報
	#  conn_id      接続ID
	#  signature    シグニチャ
	#  version      バージョン
	#
	#  to_s         ↑をストリーム化
	# ------------------------------------------------------

	class Packet
		attr_reader :event_no, :param_list, :flags, :conn_id, :signature, :version

		def initialize(eno, plist = nil, flags = nil, cid = nil, ver = nil, sig = nil)
			@event_no    = eno
			@param_list  = plist || [ ]
			@flags       = flags || 0
			@conn_id     = cid   || 0
			@signature   = sig   || "YMSG"
			@version     = ver   || 0
		end

		#
		# ストリーム化
		#
		TERM = "\300\200"
		RE_TERM = /\300\200/s
		FORMAT = "a4Cx3nnNN"

		def to_s
			param_s = @param_list.map{|p| p.join(TERM) }.join(TERM) + TERM
			[ @signature, @version, param_s.length, @event_no, @flags, @conn_id ].pack(FORMAT) + param_s
		end

		#
		# デバッグ用ダンプ
		#
		def dump(sep = " ")
			([
				"S:[#{@signature}]",
				"V:[#{@version}]",
				"E:[#{@event_no}]",
				"R:[#{"%0X" % @flags}]",
				"C:[#{"%0X" % @conn_id}]",
			] + @param_list.map{|t, v|
				"#{t}:[#{v.to_s.toeuc}]"
			}).join(sep)
		end

		# ======================================================
		# Packet::Encoder - ストリームをパケットに
		#  << s         バイト列sをのみこんでパケットを作成
		#               足りないときはnil
		#  wants        次に欲しいバイト列の長さ
		# ------------------------------------------------------

		class Encoder
			def initialize
				@buf = ""
				@body_len = nil
			end

			def <<(s)
				@buf += s
				if @body_len.nil?
					return nil if @buf.length < 20
					@sig, @ver, @body_len, @eno, @flags, @cid = @buf.unpack(FORMAT)
					@buf = @buf[20..-1]
				end
				return nil if @buf.length < @body_len
				token_list = @buf[0, @body_len].split(RE_TERM)
				@buf = @buf[@body_len..-1]
				@body_len = nil
				plist = (0...token_list.length / 2).map{|i| token_list[i * 2, 2] }
				Packet.new(@eno, plist, @flags, @cid, @ver, @sig)
			end

			def wants
				(@body_len || 20) - @buf.length
			end
		end

		# ======================================================
		# Packet::IO - 入出力(通信)
		#  new(io)
		#  write(p)      パケットpをストリーム化して送る
		#  read          パケットをひとつ読む
		# ------------------------------------------------------

		class IO
			def initialize(io)
				@io = io
				@encoder = Encoder.new
			end

			def write(packet)
				begin
# print "\n==SEND==\n", packet.dump, "\n--------\n"
					@io.write(packet.to_s)
				rescue
					nil
				end
			end

			def read
				packet = nil
				while packet.nil?
					s = @io.read(@encoder.wants)
					break if s.nil?
					packet = @encoder << s
				end
# print "\n==RECV==\n", packet.dump, "\n--------\n"
				packet
			end
		end
	end

	# ======================================================
	# Protocol - プロトコル(低レベル)
	#
	#  new(io, handler)  入出力、コールバックハンドラ
	#  close
	#
	#  送信
	#   login(myid)
	#   auth(mynick, passwd, challenge)
	#   status(status, icon, message)
	#   message(from, to)
	#
	#   login7(myid, passwd, mynick_list)
	#
	#  受信(ハンドラが用意すべきメソッド)
	#   on_login(mynick, challenge)
	#	  on_auth(myid, mynick, auth_ok)
	#   on_initial_info(mynick_list, friend_list)
	#   on_come_in(friend)
	#   on_go_out(friend)
	#		on_status(friend, status, icon, comment, on_init)
	#   on_open_session(from, to)
	#   on_message(from, to, message)
	#   on_offline_message(from, to, message, time)
	#   on_terminate()
	#   on_disconnect()
	#   on_error(message, packet)
	#   on_unknown(packet) 
	# ------------------------------------------------------

	class Protocol
		E_ONLINE      = 1
		E_OFFLINE     = 2
		E_STATUS      = 3
		E_NOSTATUS    = 4
		E_MESSAGE     = 6
		E_INV_CONF    = 24
		E_TYPING      = 75
		E_PING        = 76
		E_OPEN_SESS   = 79
		E_AUTH        = 84
		E_INIT_INFO   = 85
		E_LOGIN       = 87

		T_MYID        =  "0"
		T_MYNICK      =  "1"
		T_YANICK      =  "2"
		T_FROM        =  "4"
		T_TO          =  "5"
		T_CRYPT       =  "6"
		T_FRIEND      =  "7"
		T_NUMBER      =  "8"
		T_STATUS      = "10"
		T_CONNID      = "11"
		T_ONLINE      = "13"
		T_MESSAGE     = "14"
		T_TIME        = "15"
		T_ERROR       = "16"
		T_COMMENT     = "19"
		T_ICON        = "47"
		T_COOKIE      = "59"
		T_FRIEND_LIST = "87"
		T_MYNICK_LIST = "89"
		T_CHALLENGE   = "94"
		T_RESPONSE2   = "96"

		def initialize(io, handler)
			@packet_io = Packet::IO.new(io)
			@handler = handler
			@read_thread = Thread.start { read_loop }
		end

		def close
			@read_thread.exit
		end

		#
		# 送信
		#
		def command(*arg)
			@packet_io.write(Packet.new(*arg)) || @handler.on_disconnect()
		end

		def login(myid)
			command(E_LOGIN, [
				[ T_MYNICK, myid ],
			], 0, 0, 9)
		end

		def auth(myid, passwd, challenge)
			r1, r2 = auth_response(myid, passwd, challenge)
			command(E_AUTH, [
				[ T_MYID, myid ],
				[ T_MYNICK, myid ],
				[ T_YANICK, "1" ],
				[ T_RESPONSE2, r2 ],
				[ T_CRYPT, r1 ],
			], 12, 0, 9)
		end

		def login7(myid, passwd, mynick_list)
			command(E_ONLINE, [
				[ T_MYID, myid ],
				[ T_CRYPT, crypt_md5_unix(passwd, "_2S43d5f") ],
			] + mynick_list.map{|n| [ T_YANICK, n ] } + [
				[ T_MYNICK, myid ],
			], 12, 0, 7)
		end

		def status(status, icon, comment)
			if status.nil?
				command(E_NOSTATUS)
			else
				param_list = [ [ T_STATUS, status ] ]
				param_list << [ T_ICON, icon ] if icon
				param_list << [ T_COMMENT, mb_left(comment, 256).tosjis ] if comment
				command(E_STATUS, param_list)
			end
		end

		def message(mynick, to, message)
			command(E_MESSAGE, [
				[ T_MYNICK, mynick ],
				[ T_TO, to ],
				[ T_MESSAGE, message.tosjis ],
			], 0)
			# ], 0x5A55AA55)
			# ], 0x5A55AA56)
		end

		def invite_conference(mynick, name, message)
			require 'yaml'
			obj = YAML.load_file("conference.yaml")
			obj[name]['user'].each {|inv|
				command(E_INV_CONF, [
					["1", mynick],
					["13", 256],
					["50", mynick],
					["52", inv],
					["57", message.tosjis],
					["58", message.tosjis]
					]
				)
			}
		end

		def ping()
			command(E_PING)
		end

		#
		# 受信
		#
		def read_loop
			while packet = @packet_io.read
				parse(packet)
			end
			@handler.on_disconnect()
		end

		def parse(packet)
			list = [ param = { } ]
			packet.param_list.each do |type, value|
				if param[type]
					list << param = { }
				end
				case type
				when T_MESSAGE, T_COMMENT, T_ERROR
					value = value.toeuc
				end
				param[type] = value
			end
			p = list[0]
			if p[T_ERROR]
				@handler.on_error(p[T_ERROR], packet)
				return
			end

			case packet.event_no
			when E_LOGIN
				@handler.on_login(p[T_MYNICK], p[T_CHALLENGE])
			
			when E_AUTH
				@handler.on_auth(p[T_MYID], p[T_MYNICK], false)
			
			when E_INIT_INFO
				if packet.flags == 5
					@handler.on_initial_info(p[T_MYNICK_LIST], p[T_FRIEND_LIST])
				else
					@handler.on_unknown(packet)
				end

			when E_ONLINE
				if packet.flags == 1
					@handler.on_come_in(p[T_FRIEND])
					@handler.on_status(p[T_FRIEND], p[T_STATUS], p[T_ICON], p[T_COMMENT], false)
				else
					@handler.on_auth(p[T_MYID], p[T_MYNICK], true)
					if p[T_FRIEND]
						list.each do |p|
							@handler.on_status(p[T_FRIEND], p[T_STATUS], p[T_ICON], p[T_COMMENT], true)
						end
					end
				end

			when E_OFFLINE
				if packet.flags == 1
					@handler.on_go_out(p[T_FRIEND], p["138"].nil?)
				else
					@handler.on_terminate
				end

			when E_STATUS
				@handler.on_status(p[T_FRIEND], p[T_STATUS], p[T_ICON], p[T_COMMENT], false)
			
			when E_NOSTATUS
				if p[T_FRIEND]
					@handler.on_status(p[T_FRIEND], nil, nil, nil, false)
				else
					@handler.on_unknown(packet)
				end

			when E_MESSAGE
				if packet.flags == 5
					list.each do |p|
						@handler.on_offline_message(p[T_FROM], p[T_TO], p[T_MESSAGE], p[T_TIME])
					end
				else
					if p[T_MESSAGE] && !p[T_FROM].empty?
						@handler.on_message(p[T_FROM], p[T_TO], p[T_MESSAGE])
					else
						@handler.on_unknown(packet)
					end
				end

			when E_OPEN_SESS
				@handler.on_open_session(p[T_FROM], p[T_TO])
			
			when E_INV_CONF

			when E_TYPING
						
			else
				@handler.on_unknown(packet)
			end
		end

		#
		# sub:漢字が別れないようにnバイト以下に
		#
		def mb_left(s, n)
			n = [ n, s.length ].min
			in_kanji = false
			(0...n).each do |i|
				in_kanji = !in_kanji && s[i] >= 0x80
			end
			n = n - 1 if in_kanji
			s[0, n]
		end

		#
		# sub:暗号化
		#
		def to64(x, i)
			ret = ""
			while i > 0
				ret << "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"[x % 64]
				x = x / 64
				i = i - 1
			end
			ret
		end

		def crypt_md5_unix(passwd, salt)
			salt = salt.sub(/^\$1\$/, "").sub(/\$[^$]*$/, "")[0...8]
			digest = Digest::MD5.new(passwd + salt + passwd).digest
			md5 = Digest::MD5.new(passwd + "$1$" + salt)

			len = passwd.length
			while len > 0
				md5.update(digest[0...[len, 16].min])
				len = len - 16
			end

			len = passwd.length
			while len > 0
				md5.update(len % 2 > 0 ? "\0" : passwd[0].chr)
				len = len / 2
			end
			digest = md5.digest

			for i in 0...1000
				md5 = Digest::MD5.new
				md5.update(i % 2 > 0 ? passwd : digest[0...16])
				md5.update(salt) if i % 3 > 0
				md5.update(passwd) if i % 7 > 0
				md5.update(i % 2 > 0 ? digest[0...16] : passwd)
				digest = md5.digest
			end

			crypt = begin
				to64(digest[0] << 16 | digest[6] << 8 | digest[12], 4) +
				to64(digest[1] << 16 | digest[7] << 8 | digest[13], 4) +
				to64(digest[2] << 16 | digest[8] << 8 | digest[14], 4) +
				to64(digest[3] << 16 | digest[9] << 8 | digest[15], 4) +
				to64(digest[4] << 16 | digest[10] << 8 | digest[5], 4) +
				to64(digest[11], 2)
			end

			"$1$" + salt + "$" + crypt
		end

		#
		# sub:認証
		#
		def bm(s)
			[ Digest::MD5.new(s).digest ].pack("m").sub(/\n/, "").tr("+/=", "._-")
		end

		def auth_response(id, passwd, challenge)
			tab1 = [ id, bm(passwd), challenge ]
			tab2 = [ id, bm(crypt_md5_unix(passwd, "_2S43d5f")), challenge ]
			order = [
				[  7, 1, 0, 2 ],
				[  9, 0, 2, 1 ],
				[ 15, 2, 1, 0 ],
				[  1, 0, 1, 2 ],
				[  3, 1, 2, 0 ],
			]
			f0, f1, f2, f3 = order[challenge[15] % 8 % 5]
			c = challenge[challenge[f0] % 16, 1]
			r1 = bm(c + tab1[f1] + tab1[f2] + tab1[f3])
			r2 = bm(c + tab2[f1] + tab2[f2] + tab2[f3])
			return r1, r2
		end
	end

	# ======================================================
	# モジュール - イベントハンドラ
	# ------------------------------------------------------

	module EventHandler
		def register_handler(handler, event_list)
			event_list.each do |event|
				((@dispatch_tab ||= { })[event] ||= [ ]) << handler
			end
		end

		def unregister_handler(handler, event_list = nil)
			(event_list || @dispatch_tab.keys).each do |event|
				(@dispatch_tab[event] || [ ]).delete(handler)
			end
		end

		def dispatch(*arg)
			((@dispatch_tab || { })[arg[0]] || [ ]).each do |handler|
				handler.__send__(*arg)
			end
		end
	end

	# ======================================================
	# プロトコルハンドラ
	#
	#   new
	#   close
	#
	#  操作
	#   login_auth(myid, passwd)
	#   loign7(myid, passwd)
	#   set_status(status, icon, comment)
	#   send_message(mynick, to, message)
	#   ping()
	#
	#  生成イベント
	#   on_get_chat_server(host, port)
	#   on_get_mynick_list(mynick_list)
	#   on_get_friend_tab(friend_tab)
	#   on_login(mynick, challenge)
	#   on_auth_ok(myid, mynick)
	#   on_auth_ng(myid, mynick)
	#   on_come_in(friend)
	#   on_go_out(friend)
	#   on_hide(friend)
	#   on_terminate()
	#   on_status(friend, status, icon, comment)
	#   on_change_icon(friend, icon, pre_icon, comment)
	#   on_change_comment(friend, comment, pre_comment, icon)
	#   on_message(from, to, message, raw_message)
	#   on_offline_message(from, to, message, raw_message, time)
	#   on_open_session(from, to)
	#   on_disconnect()
	#   on_erorr(message, packet)
	#   on_unknown(packet)
	# ------------------------------------------------------

	class ProtocolHandler
		include EventHandler

		TAB_ICON = {
			I_NORMAL  = "0" => :none,
			I_BUSY    = "1" => :busy,
			I_IDLE    = "2" => :idle,
			I_HIDE    = "h" => :hide,
			I_GAME    = "g" => :game,
		}

		TAB_STATUS = {
			S_READY    =   "0" => [ I_NORMAL, nil ],
			S_WILLBACK =   "1" => [ I_BUSY, "すぐ戻ります" ],
			S_BUSY     =   "2" => [ I_BUSY, "ただいま多忙" ],
			S_O_HOME   =   "3" => [ I_BUSY, "家にいません" ],
			S_AWAY     =   "4" => [ I_BUSY, "席をはずしています" ],
			S_O_OFFICE =   "5" => [ I_BUSY, "オフィスにいません" ],
			S_PHONE    =   "6" => [ I_BUSY, "電話中" ],
			S_VACATION =   "7" => [ I_BUSY, "休暇中" ],
			S_LUNCH    =   "8" => [ I_BUSY, "食事中" ],
			S_HOME     =   "9" => [ I_BUSY, "帰宅" ],
			S_HIDE     =  "12" => [ I_HIDE, "ログイン状態を隠す" ],
			S_FREE     =  "99" => [ nil, nil ],
			S_IDLE     = "999" => [ I_IDLE, "アイドル" ],
		}

		def initialize
			@mutex = Mutex.new
			@status_tab = { }
		end

		def connect
			host, port = YahooJ.get_chat_server
			dispatch(:on_get_chat_server, host, port)
			@io = TCPSocket.new(host, port)
			@protocol = Protocol.new(@io, self)
		end

		def close
			@protocol.close
			@io.close
		end

		def login(myid)
			connect
			@protocol.login(myid)
		end

		def auth(myid, passwd, challenge)
			@protocol.auth(myid, passwd, challenge)
		end

		def login_auth(myid, passwd)
			@passwd = passwd
			@mutex.lock
			login(myid)
			@mutex.lock.unlock
		end

		def login7(myid, passwd)
			mynicks, friends = YahooJ.get_nick_info(myid, passwd)
			on_initial_info(mynicks, friends)
			connect
			@protocvol.login7(myid, passwd, mynick_list)
		end

		def set_status(icon, comment)
			status, icon, comment = 
			case icon
			when :hide
				[ S_HIDE, nil, nil ]
			when :busy
				comment ? [ S_FREE, I_BUSY, comment ] : [ S_BUSY, nil, nil ]
			when :idle
				comment ? [ S_FREE, I_IDLE, comment ] : [ S_IDLE, nil, nil ]
			else
				comment ? [ S_FREE, I_NORMAL, comment ] : [ nil, nil, nil ]
			end
			@protocol.status(status, icon, comment)
		end

		def get_status
			@status_tab
		end

		def send_message(mynick, to, message)
			@protocol.message(mynick, to, message)
		end

		def invite_conference(mynick, name, message)
			@protocol.invite_conference(mynick, name, message)
		end

		def ping()
			@protocol.ping()
		end

		#
		# call back from @protocol
		#
		def on_login(mynick, challenge)
			auth(mynick, @passwd, challenge) if @mutex.locked?
			dispatch(:on_login, mynick, challenge)
		end

		def on_auth(myid, mynick, auth_ok)
			if auth_ok
				dispatch(:on_auth_ok, myid, mynick)
			else
				dispatch(:on_auth_ng, myid, mynick)
			end
			@mutex.unlock
		end

		def on_initial_info(mynicks, friends)
			mynick_list = [ ]
			mynicks.split("\n").each do |line|
				mynick_list += line.split(",")
			end
			dispatch(:on_get_mynick_list, mynick_list)
			friend_tab = { }
			friends.split("\n").each do |line|
				group, friend_list = line.split(":")
				(friend_tab[group.toeuc] ||= [ ]).concat(friend_list.split(","))
			end
			dispatch(:on_get_friend_tab, friend_tab)
		end

		def on_come_in(friend)
			@status_tab[friend] = [ nil, nil ]
			dispatch(:on_come_in, friend)
		end

		def on_go_out(friend, is_true)
			@status_tab.delete(friend)
			if is_true
				dispatch(:on_go_out, friend)
			else
				dispatch(:on_hide, friend)
			end
		end

		def on_terminate()
			dispatch(:on_terminate)
		end

		def on_status(friend, status, icon, comment, on_init)
			icon, comment = regularize_status(status, icon, comment)
			p_icon, p_comment = @status_tab[friend]
			@status_tab[friend] = [ icon, comment ]
			return if on_init

			dispatch(:on_status, friend, icon, comment)
			if icon != p_icon
				dispatch(:on_change_icon, friend, icon, p_icon, comment)
			end
			if comment != p_comment
				dispatch(:on_change_comment, friend, comment, p_comment, icon)
			end
		end

		def on_message(from, to, raw_message)
			dispatch(:on_message, from, to, strip_message(raw_message), raw_message)
		end

		def on_offline_message(from, to, raw_message, time)
			dispatch(:on_offline_message, from, to, strip_message(raw_message), raw_message, time.to_i)
		end

		def on_open_session(from, to)
			dispatch(:on_open_session, from, to)
		end

		def on_disconnect()
			dispatch(:on_disconnect)
		end

		def on_error(message, packet)
			dispatch(:on_error, message, packet)
		end

		def on_unknown(packet)
			dispatch(:on_unknown, packet)
		end

		#
		# sub:strip
		#
		def strip_message(raw_message)
			raw_message.gsub(/\033[^A-Za-z]*[A-Za-z]/, "").gsub(/<(font|FADE|\/FADE)[^>]*>/, "")
		end

		#
		# sub:ステータス情報の整理
		#
		def regularize_status(status, icon, comment)
			c_icon, c_comment = TAB_STATUS[status || S_READY] || [ "?", nil ]
			icon = TAB_ICON[icon || c_icon] || :unknown
			comment ||= c_comment
			return icon, comment
		end
	end

	# ======================================================
	# 単純なクライアントの雛型
	#
	# 操作
	#  login(myid, passwd)
	#  send_maeesage(to, message)
	#  set_icon(icon)
	#  set_comment(comment)
	#  get_status
	#  exists?(name)
	#  online?(name)
	#  auth_ok?(id, passwd)
	#  ping()
	#
	# 上書き
	#  on_get_chat_server(host, port)
	#  on_get_mynick_list(mynick_list)
	#  on_get_friend_tab(friend_tab)
	#  on_auth_ok(myid, mynick)
	#  on_auth_ng(myid, mynick)
	#  on_message(from, to, message, raw_message)
	#  on_offline_message(from, to, message, raw_message, time)
	#  on_come_in(name)
	#  on_go_out(name)
	#  on_hide(name)
	#  on_change_icon(name, icon, p_icon, comment)
	#  on_change_comment(name, comment, p_comment, icon)
	#  open_session(from, to)
	#  on_terminate
	#  on_disconnect
	#  on_error(message, packet)
	#  on_unknown(packet)
	# ------------------------------------------------------

	class SimpleClient

		def initialize
			@ph = ProtocolHandler.new
			@ph.register_handler(self, [
				:on_get_chat_server,
				:on_get_mynick_list,
				:on_get_friend_tab,
				:on_auth_ok,
				:on_auth_ng,
				:on_terminate,
				:on_message,
				:on_offline_message,
				:on_open_session,
				:on_disconnect,
				:on_erorr,
				:on_unknown,
				:on_come_in,
				:on_go_out,
				:on_hide,
				:on_change_icon,
				:on_change_comment,
			])
#			@sm = StatusManager.new(@ph)
#			@sm.register_handler(self, [
#				:on_come_in,
#				:on_go_out,
#				:on_change_icon,
#				:on_change_comment,
#			])
		end

		def login(myid, passwd)
			@myid = myid
			@ph.login_auth(myid, passwd)
		end

		def send_message(to, message)
			@ph.send_message(@myid, to, message)
		end

		def invite_conference(name, message)
			@ph.invite_conference(@myid, name, message)
		end

		def set_status(icon, comment)
			@ph.set_status(icon, comment)
		end

		def get_status
			@ph.get_status
		end

		def exists?(name)
			YahooJ.exists?(name)
		end

		def online?(name)
			YahooJ.online?(name)
		end

		def auth_ok?(id, passwd)
			YahooJ.auth_ok?(id, passwd)
		end

		def ping()
			@ph.ping()
		end

		def on_get_chat_server(host, port)
		end

		def on_get_mynick_list(mynick_list)
		end

		def on_get_friend_tab(friend_tab)
		end

		def on_auth_ok(myid, mynick)
		end

		def on_auth_ng(myid, mynick)
		end

		def on_message(from, to, message, raw_message)
		end

		def on_offline_message(from, to, message, raw_message, time)
		end

		def on_come_in(name)
		end

		def on_go_out(name)
		end

		def on_hide(name)
		end

		def on_change_icon(name, icon, p_icon, comment)
		end

		def on_change_comment(name, comment, p_comment, icon)
		end

		def open_session(from, to)
		end

		def on_terminate
		end

		def on_disconnect
		end

		def on_error(message, packet)
		end

		def on_unknown(packet)
		end
	end
end

# --------------------------------------------------------------

	end
end

# ======================================================================
# * 2.03  2005-04-06
# - get_chat_server の見に行く先を修正
# ----------------------------------------------------------------------
# * 2.00  2002-06-27
# - イベントハンドラ形式に大改造
# - ver9対応
# ----------------------------------------------------------------------
# * 1.12  2002-01-12
# - create
# ----------------------------------------------------------------------
# net/im/yahooj.rb
