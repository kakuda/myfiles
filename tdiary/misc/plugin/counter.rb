# counter.rb $Revision: 1.19 $
#
# Access counter plugin.
#
# 1. Usage
# counter(figure, filetype = ""): Show number of all visitors.
# counter_today(figure, filetype = ""): Show number of visitors for today.
# counter_today(figure, filetype = ""): Show number of visitors for yesterday.
#	 filetype: jpg, gif, png ... .
#
# kiriban?: Return true when the number is a kiriban.
# kiriban_today?: Return true when the number is a kiriban(for today's couner).
#
# counter
# counter 3
# coutner 3, "jpg"
# counter_today 4, "jpg"
# counter_yesterday
#
# 2. Documents
# See URLs below for more details.
#   http://ponx.s5.xrea.com/hiki/counter.rb.html (English) 
#   http://ponx.s5.xrea.com/hiki/ja/counter.rb.html (Japanese) 
#
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 
=begin ChangeLog
2003-11-15 MUTOH Masao  <mutoh@highway.ne.jp>
   * translate documents to English.

2003-02-15 MUTOH Masao  <mutoh@highway.ne.jp>
   * counter.dat���礭���ʤ��Զ��ν���
   * version 1.6.3

2002-11-26 Junichiro Kita <kita@kitaj.no-ip.com>
   * remove 'cgi.cookies = nil' in TDiaryCounter::main

2002-11-19 TADA Tadashi <sho@spc.gr.jp>
   * for squeeze.rb error more.
   * version 1.6.2

2002-11-13 TADA Tadashi <sho@spc.gr.jp>
   * for squeeze.rb error.

2002-10-12 MUTOH Masao  <mutoh@highway.ne.jp>
   * ���ƻȤ��Ȥ���ư��ʤ��ʤäƤ����Զ��ν�����
   * 1��1���ݻ����Ƥ���桼������򥯥꡼�󥢥åפ���褦�ˤ�����
   * version 1.6.1

2002-08-30 MUTOH Masao  <mutoh@highway.ne.jp>
   * �ǡ����ե����뤬�ɤ߹���ʤ��ʤä��Ȥ���1�����ΥХå����åץǡ���
     ���Ѥ������줹��褦�ˤ���(���κݤˡ�1�����ΥХå����åץǡ�����
     counter.dat.?.bak�Ȥ���̾���ǥХå����åפ����)�������1������
     �Хå����åץǡ������������Ǥ��ʤ��ä��������ƤΥ������ͤ�
     0�ˤ��ƥ��顼���̤�ɽ������ʤ��褦�ˤ�����
   * version 1.6.0

2002-07-23 MUTOH Masao  <mutoh@highway.ne.jp>
   * �Хå����åץե�����Υե�����̾��suffix������(0-6�ο���)�ˤ�����
      ���äơ�1������˸Ť��ե�����Ͼ�񤭤����Τǥե�����ο���
      ����7�ĤȤʤ롣��������������Τ��ǿ��Ȥ����櫓�ǤϤʤ��Τ���ա�
      (proposed by Junichiro KITA <kita@kitaj.no-ip.com>)
   * version 1.5.1

2002-07-19 MUTOH Masao  <mutoh@highway.ne.jp>
   * ����ñ�̤ǥǡ�����Хå����åפ���褦�ˤ�����
     @options["counter.dairy_backup"]�ǻ��ꡣfalse����ꤷ�ʤ��¤�
     �Хå����åפ��롣
   * Date#==�᥽�åɤ�nil���Ϥ��ʤ��褦�˽���
   * require 'pstore'�ɲ�(tDiary version 1.5.x���б�)
   * log�Υե����ޥå��ѹ�(���ơ������������Υǡ��������)
   * @options["counter.deny_same_src_interval"]�Υǥե�����ͤ�2����
     ���ѹ�������
   * version 1.5.0

2002-05-19 MUTOH Masao  <mutoh@highway.ne.jp>
   * Cookie��Ȥ����ȤΤǤ��ʤ�Ʊ�쥯�饤����Ȥ����Ϣ³����������
     ������ȥ��åפ��ʤ��褦�ˤ�����
   * @options["counter.deny_same_src_interval"]�ɲá�Ϣ³GET�δֳ֤���ꡣ
     �ǥե���Ȥ�0.1����(6ʬ)��
   * version 1.4.0

2002-05-11 MUTOH Masao  <mutoh@highway.ne.jp>
   * ����ͤ�Ϳ���ʤ�����5��Ȥ��Ƥ�����������0��ʤ����פ��ѹ�������
     �ޤ�����0��̵��������0����ꤷ�Ƥ��ɤ���
   * version 1.3.0

2002-05-05 MUTOH Masao  <mutoh@highway.ne.jp>
   * @debug = true ��� :->
   * �������ѹ�
   * version 1.2.1

2002-05-04 MUTOH Masao  <mutoh@highway.ne.jp>
   * tlink�ץ饰���󤫤�Υ��������򥫥���Ȥ��Ƥ��ޤ��Զ��ν���
   * @options["counter.deny_user_agents"]�ɲ�
   * @options["counter.deny_remote_addrs"]�ɲ�
   * @options["counter.init_num"]�ɲá������ֵ�ǽ�Ȥδط��ǡ�counter
   * �᥽�åɤΰ�����init_num��obsolete�Ȥ��ޤ���
   * @options["counter.kiriban"], @options["counter.kiriban_today"]�ɲ�
   * �����ֵ�ǽ�ɲ�(kiriban?,kiriban_today?�᥽�å��ɲ�)
   * version 1.2.0

2002-04-27 MUTOH Masao  <mutoh@highway.ne.jp>
   * add_header_proc��Ȥ�ʤ��褦�ˤ���
   * @options["counter.timer"]��ͭ���ˤʤ�ʤ��Զ��ν���
   * @options["counter.log"]�ɲá�true����ꤹ���counter.dat
      ��Ʊ���ǥ��쥯�ȥ��counter.log�Ȥ����ե�����������
      1�����Υ�����������Ͽ����褦�ˤ���
   * cookie���ͤȤ��ƥС�������ֹ�������褦�ˤ���
   * version 1.1.0

2002-04-25 MUTOH Masao  <mutoh@highway.ne.jp>
   * HEAD�ǥ������������ä����˺Ƥӥ�����Ȥ����褦��
      �ʤäƤ��ޤäƤ����Զ��ν���(by NT<nt@24i.net>)
   * version 1.0.4

2002-04-24 MUTOH Masao  <mutoh@highway.ne.jp>
   * �ĥå��ߤ����줿�Ȥ��˥��顼��ȯ�������Զ��ν���
   * version 1.0.3

2002-04-23 MUTOH Masao  <mutoh@highway.ne.jp>
   * �ǡ����ե���������塢���å�����ͭ���������ü������
      ����������������@today��0�ˤʤ��Զ��ν���
   * ���������줿�Ȥ��˿�����ɽ������ʤ��Զ��ν���
   * HEAD�ǥ������������ä����ϥ�����Ȥ��ʤ��褦�ˤ���
      (reported by NT<nt@24i.net>, suggested a solution 
         by TADA Tadashi <sho@spc.gr.jp>)
   * version 1.0.2

2002-04-21 MUTOH Masao  <mutoh@highway.ne.jp>
   * CSS��_��ȤäƤ���Ȥ����-��ľ����(reported by NT<nt@24i.net>)
   * TDiaryCountData#up��@all��+1����ʤ��Զ��ν���
   * version 1.0.1

2002-04-14 MUTOH Masao  <mutoh@highway.ne.jp>
   * version 1.0.0
=end


if ["latest", "month", "day"].include?(@mode) and 
	ENV['REQUEST_METHOD'] == 'GET'

require 'date'
require 'pstore'

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
class TDiaryCountData
	attr_reader :today, :yesterday, :all, :newestday, :ignore_cookie
	attr_writer :ignore_cookie #means ALWAYS ignore a cookie.

	def initialize
	  @today, @yesterday, @all = 0, 0, 0
	  @newestday = nil
	  @ignore_cookie = false
	end

	def up(now, cache_path, cgi, log)
	  if @newestday
		if now == @newestday
		  @today += 1
		else
		  log(@newestday, cache_path) if log
		  @yesterday = ((now - 1) == @newestday) ? @today : 0
		  @today = 1
		  @newestday = now
        time = Time.now
		  @users.reject!{|key, val|
			 time - val > 2 * 3600
		  }
		end
	  else
		@yesterday = 0
		@today = 1
		@newestday = now
	  end
	  @all += 1
	end

	def previous_access_time(remote_addr, user_agent, interval)
	  @users = Hash.new unless @users
	  now = Time.now

	  ret = @users[[remote_addr, user_agent]]
	  @users[[remote_addr, user_agent]] = now
	  ret
	end

	def log(day, path)
	  return unless day
	  open(path + "/counter.log", "a") do |io|
		io.print day, " : ", @all, ",", @today, ",", @yesterday, "\n"
	  end
	end
end
TOPLEVEL_CLASS

module TDiaryCounter
	@version = "1.6.2"

	def run(cache_path, cgi, options)
		timer = options["counter.timer"] if options
		timer = 12 unless timer	# 12 hour
		@init_num = options["counter.init_num"] if options
		@init_num = 0 unless @init_num
		dir = cache_path + "/counter"
		path = dir + "/counter.dat"
		today = Date.today
		Dir.mkdir(dir, 0700) unless FileTest.exist?(dir)
	
		cookie = nil
		begin
		  cookie = main(cache_path, cgi, options, timer, dir, path, today)
		rescue
		  back = (Dir.glob(path + ".?").sort{|a,b| File.mtime(a) <=> File.mtime(b)}.reverse)[0]
		  
		  if back
			copy(back, back + ".bak")
			copy(back, path)
		  else
			rm(path)
		  end
		  begin
			cookie = main(cache_path, cgi, options, timer, dir, path, today)
		  rescue 
			@cnt = TDiaryCountData.new
		  end
		end
		cookie
	end

	def main(cache_path, cgi, options, timer, dir, path, today)
		cookie = nil
		db = PStore.new(path)
		db.transaction do
			begin
				@cnt = db["countdata"]
			rescue PStore::Error
			end
            unless @cnt
              @cnt = TDiaryCountData.new
            end

			allow = (cgi.user_agent !~ /tlink/ and
						allow?(cgi.user_agent, options, "user_agents") and
						allow?(cgi.remote_addr, options, "remote_addrs"))
			if allow 
				changed = false
				if new_user?(cgi, options)
					@cnt.up(today, dir, cgi, (options and options["counter.log"]))
					cookie = CGI::Cookie.new({"name" => "tdiary_counter", 
														"value" => @version, 
														 "expires" => Time.now + timer * 3600})
					changed = true
				end
				if options["counter.kiriban"]
					@kiriban = options["counter.kiriban"].include?(@cnt.all + @init_num) 
				end
 				if ! @kiriban and options["counter.kiriban_today"]
					@kiriban_today = options["counter.kiriban_today"].include?(@cnt.today)
				end

				if @cnt.ignore_cookie
					@cnt.ignore_cookie = false
					changed = true
				end

				#when it is kiriban time, ignore the cookie next access time. 
				if @kiriban or @kiriban_today
					@cnt.ignore_cookie = true
					changed = true
				end

				if changed
					if options["counter.daily_backup"] == nil || options["counter.daily_backup"] 
						copy(path, path + "." + today.wday.to_s)
					end
					db["countdata"] = @cnt
				end
			end
		end
		cookie
	end

	def rm( fn, force = true )
	  first = true
	  begin
		File.unlink fn
	  rescue Errno::ENOENT
		force or raise
	  rescue
		# rescue dos?
		begin
		  if first then
			first = false
			File.chmod 0777, fn
			retry
		  end
		rescue
		end
	  end
	end

	def copy(old, new)
		if FileTest.exist?(old)
			File.open(old,  'rb') {|r|
				File.open(new, 'wb') {|w|
					st = r.stat
					begin
						while true do
							w.write r.sysread(st.blksize)
						end
					rescue EOFError
					end
				} 
			}
		end
	end
		
	def allow?(cgi_value, options, option_name)
		allow = true
		if options and options["counter.deny_" + option_name] 
			options["counter.deny_" + option_name].each do |deny|
				if cgi_value =~ /#{deny}/
					allow = false
					break
				end
			end
		end
		allow 
	end

	def new_user?(cgi, options)
		if ! cgi.cookies or ! cgi.cookies.keys.include?("tdiary_counter")
			interval = options["counter.deny_same_src_interval"] if options
			interval = 2 unless interval	# 2 hour.
			previous_access_time = @cnt.previous_access_time(cgi.remote_addr, cgi.user_agent, interval)
			if previous_access_time
				ret = Time.now - previous_access_time > interval * 3600
			else
				ret = true
			end
		else
			ret = @cnt.ignore_cookie
		end
		ret
	end

	def format(classtype, theme_url, cnt, figure = 0, filetype = "", init_num = 0, &proc)
		str = "%0#{figure}d" % (cnt + init_num)
		result = %Q[<span class="counter#{classtype}">]
		depth = 0
		str.scan(/./).each do |num|
			if block_given?
				result << %Q[<img src="#{theme_url}/#{yield(num)}" alt="#{num}" />]
			elsif filetype == ""
				result << %Q[<span class="counter-#{depth}"><span class="counter-num-#{num}">#{num}</span></span>]
			else 
				result << %Q[<img src="#{theme_url}/#{num}.#{filetype}" alt="#{num}" />]
			end
			depth += 1
		end
		result << "</span>"
	end

	def called?; @called; end
	def called; @called = true; end
	def all; @cnt.all + @init_num; end
	def today; @cnt.today; end
	def yesterday; @cnt.yesterday; end
	def kiriban?; @kiriban; end
	def kiriban_today?; @kiriban_today; end

	module_function :allow?, :new_user?, :all, :today, :yesterday, :format, 
							:main, :run, :copy, :rm, :kiriban?, :kiriban_today?
end

#init_num is deprecated.
#please replace it to @options["counter.init_num"]
def counter(figure = 0, filetype = "", init_num = 0, &proc) 
	TDiaryCounter.format("", theme_url, TDiaryCounter.all, figure, filetype, init_num, &proc)
end

def counter_today(figure = 0, filetype = "", &proc)
	TDiaryCounter.format("-today", theme_url, TDiaryCounter.today, figure, filetype, 0, &proc)
end

def counter_yesterday(figure = 0, filetype = "", &proc)
	TDiaryCounter.format("-yesterday", theme_url, TDiaryCounter.yesterday, figure, filetype, 0, &proc)
end

def kiriban?
	TDiaryCounter.kiriban?
end

def kiriban_today?
	TDiaryCounter.kiriban_today?
end

tdiary_counter_cookie = TDiaryCounter.run(@cache_path, @cgi, @options)
if tdiary_counter_cookie
	if defined?(add_cookie)
		add_cookie(tdiary_counter_cookie)
	else
		@cookie = tdiary_counter_cookie if tdiary_counter_cookie
	end
end

end
