#!/usr/bin/env ruby
# ======================================================================
# ymc - 簡単なYahoo!メッセンジャークライアント
#
# 0.12  2002-01-12
# 0.13  2005-04-06
# ----------------------------------------------------------------------

require "net-im-yahooj"

$DEBUG = 1

class MyClient < Net::IM::YahooJ::SimpleClient

	#
	# tool
	#
	def print(*arg)
		STDOUT.print(*arg)
		if @log_fh
			@log_fh.print(*arg)
			@log_fh.flush
		end
	end

	def sysmsg(*arg)
		print "[system] "
		print(*arg)
		print "\n"
	end

	def show_time
		sysmsg(Time.now.strftime("%Y-%m-%d:%H:%M:%S"))
	end

	ICON_TAB = {
		:none => "r",
		:idle => "i",
		:busy => "b",
		:hide => "h",
		:game => "g",
	}

	def show_status(friend, icon, comment)
		icon_s = ICON_TAB[icon] || "?"
		sysmsg("#{icon_s} #{friend}", comment ? " - #{comment}" : "")
	end

	def show_who
		show_status(@nick, @icon, @comment)
		status_tab = get_status
		status_tab.keys.sort.each do |friend|
			icon, comment = *status_tab[friend]
			show_status(friend, icon, comment)
		end
	end

	def check_friend
	end

	def show_friend
		sysmsg("you are talking to ", @friend ? "#{@friend}" : "nobody. use #{@esc}sw", ".")
	end

	def show_echo
		sysmsg("echo is ", @echo ? "on" : "off", ".")
	end

	def show_esc
		if @esc.length == 1
			sysmsg("escape char is '#{@esc}'.")
		else
			sysmsg("escape string is \"#{@esc}\".")
		end
	end

	def ping
		# system("ping")
	end

	# 
	# event
	#

	def on_get_chat_server(host, port)
		sysmsg("server: #{host}:#{port}")
	end

	def on_get_mynick_list(mynick_list)
		sysmsg("mynick: ", mynick_list.join(", "))
	end

	def on_login(mynick, challenge)
		sysmsg("login: #{mynick} ? #{challenge}")
	end

	def on_auth_ok(myid, mynick)
		sysmsg("auth ok: #{myid} (#{mynick})")
		show_esc
		show_echo
		show_friend
	end

	def on_auth_ng(myid, mynick)
		sysmsg("AUGH NG: #{myid} (#{mynick})")
	end

	def on_get_friend_tab(friend_tab)
		return
		friend_tab.each do |group, list|
			sysmsg("#{group} => ", list.join(", "))
		end
	end

	def on_come_in(friend)
		sysmsg("#{friend} comes in.")
	end

	def on_go_out(friend)
		sysmsg("#{friend} goes out.")
	end

	def on_hide(friend)
		sysmsg("#{friend} hides him/herself.")
	end

	def on_terminate()
		sysmsg("you logged in from another client. bye.")
	end

	def on_change_icon(friend, icon, pre_icon, comment)
	end

	def on_change_comment(friend, comment, pre_comment, icon)
		show_status(friend, icon, comment)
	end

	def on_message(from, to, message, raw_message)
		print "[#{from}] #{message}\n"
	end

	def on_offline_message(from, to, message, raw_message, time)
		time_s = Time.at(time).strftime("%Y/%m/%d %a %H:%M:%S")
		print "[#{from}] #{message} (#{time_s})\n"
	end

	def on_open_session(from, to)
		sysmsg("session: #{from} <-> #{to}")
	end

	def on_disconnect()
		sysmsg("end of line.")
		exit 0
	end

	def on_error(message, packet)
		return
		sysmsg("error: #{message}")
		print packet.dump
		sysmsg("\n----")
	end

	def on_unknown(packet)
		return
		sysmsg("unknown: ----")
		print packet.dump
		sysmsg("\n----")
	end

	#
	# console
	#
	def handle_stdin(line)
		message = line.chomp
		# if !message.empty? && message[0].chr == @esc
		#	c = message[1..-1].split
		if message.index(@esc) == 0
			c = message[@esc.length .. -1].split
			case c[0]
			when "e", "ex", "exit"
				exit 0

			when "sh", "shell"
				sysmsg("type \"exit\" when back.")
				system(ENV["SHELL"])
				sysmsg("welcome back.")

			when "sw", "switch"
				if c[1]
					@friend = c[1]
					check_friend
				end
				show_friend

			when "st", "stat", "status"
				@icon = :none
				@comment = message.split(/\s+/, 2)[1]
				set_status(@icon, @comment)
				show_status(@nick, @icon, @comment)

			when "busy"
				@icon = :busy
				@comment = message.split(/\s+/, 2)[1]
				set_status(@icon, @comment)
				show_status(@nick, @icon, @comment)

			when "idle"
				@icon = :idle
				@comment = message.split(/\s+/, 2)[1]
				set_status(:hide, nil)
				set_status(@icon, @comment)
				show_status(@nick, @icon, @comment)

			when "nost", "nostat", "nostatus"
				@icon = :none
				@comment = nil
				set_status(@icon, @comment)
				show_status(@nick, @icon, @comment)

			when "hide"
				@icon = :hide
				@comment = "ログイン状態を隠す"
				set_status(@icon, nil)
				show_status(@nick, @icon, @comment)


			when "w", "who"
				show_who

			when "echo"
				@echo = !(c[1] =~ /^of/) if c[1]
				show_echo

			when "esc", "escape"
				if c[1]
					if c[1] =~ /[\x21-\x7e]+/
						@esc = c[1] if c[1]
					else
						sysmsg("escape: must be ASCII char(s)")
					end
					show_esc
				end

			when "nick"

			when "t", "time"
				show_time
			when "con"
				@comment = message.split(/\s+/, 3)
				invite_conference(@comment[1], @comment[2])

			else
				sysmsg("#{@esc}e #{@esc}ex #{@esc}exit")
				sysmsg("#{@esc}w #{@esc}who")
				sysmsg("#{@esc}sw #{@esc}switch <name>")
				sysmsg("#{@esc}st #{@esc}status <comment>")
				sysmsg("#{@esc}busy <comment>")
				sysmsg("#{@esc}idle <comment>")
				sysmsg("#{@esc}nost #{@esc}nostat #{@esc}nostatus")
				sysmsg("#{@esc}hide")
				sysmsg("#{@esc}echo {on|off}")
				sysmsg("#{@esc}t #{@esc}time")
				sysmsg("#{@esc}esc #{@esc}escape")
			end
		else
			if @friend.nil? || message.empty?
				show_friend
			else
				send_message(@friend, message)
				print "[#{@nick}] #{message}\n" if @echo
			end
		end
	end

	def run(nick, friend, hide)
		@nick = nick
		@friend = friend
		@hide = hide
		@echo = true
		@esc = "/"
		@log_fh = begin
			open("#{ENV["HOME"]}/ym_log", "a", 0600)
		rescue
			nil
		end

		if @nick.nil? || @nick.empty?
			print "login: "
			@nick = STDIN.gets.chomp
		end

		print "password: "
		system("stty -echo")
		begin
			passwd = STDIN.gets.chomp
		ensure
			print "\n"
			system("stty echo")
		end

#		if !@ym.login_ok?(@nick, passwd)
#			print "#{$0}: #{@nick}: wrong name/passwd\n"
#			exit 2
#		end

		show_time

		login(@nick, passwd)

		if hide
			@icon = :hide
			@comment = "ログイン状態を隠す"
		else
			@icon = :none
			@comment = nil
			set_status(@icon, @comment)
		end

		loop do
			rs, = select([ STDIN ], nil, nil, 600)
			if rs
				rs.each do |s|
					case s
					when STDIN
						handle_stdin(STDIN.gets)
					end
				end
			else
				ping
			end
		end
	end

end

# hide = false
# if ARGV[0] == "-h" || ARGV[0] == "--hide"
# 	ARGV.shift
# 	hide = true
# end
# nick, friend = *ARGV

# MyClient.new.run(nick, friend, hide)

# ----------------------------------------------------------------------
# vi:ts=2 sw=2:
