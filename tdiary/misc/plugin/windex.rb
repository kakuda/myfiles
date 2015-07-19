#!/usr/bin/env ruby-1.6
$KCODE = 'n'

# windex.rb $Revision: 1.4 $
#
# windex: ��������������
#   �ѥ�᥿:
#     str:      �������ʸ����
#     readname: �ɤ߲�̾
#
# wikw: �������饢�󥫡�����������
#   �ѥ�᥿:
#     str:      �������ʸ����
#
# ���Υե������tDiary�Υȥåץǥ��쥯�ȥ�ˤ����֤���CGI�Ȥ���
# �¹Ԥ��뤳�ȤǺ����ڡ�������ϤǤ��ޤ���
#
# CGIư����ΰ���
#   http://(����URL)/windex.rb?kw=(�������ʸ����)
#   �ȥ�����ɤ���ꤷ�ƥ����������뤳�ȤǤ��Υ�����ɤ˴ط�����������
#   ���հ�������ϤǤ��ޤ�����Ĥ����ξ��ˤϤ������դ������ؤ�
#   ������쥯�Ȥ���Ϥ��ޤ���
#
# tdiary.conf�ˤ������
#   @options['windex.generate_all'] = true
#     ���Ƥ���������������������ޤ�������ϻ��֤�������Τǡ���������������
#     �Ԥ������Ȥ�����true�����ꤷ�ƹ�����Ԥ��褦�ʻȤ��������ꤷ�Ƥ��ޤ���
#
# Copyright (c) 2003 Gony <gony@sm.rim.or.jp>
# Distributed under the GPL
#

$KCODE= "e"

mode = ""
if $0 == __FILE__
	mode = "CGI"
	if FileTest.symlink?(__FILE__) == true
		org_path = File.dirname(File.readlink(__FILE__))
	else
		org_path = File.dirname(__FILE__)
	end
	$:.unshift(org_path)
	require "pstore"
	require "tdiary"

	tdiarybase = TDiary::TDiaryBase
else
	tdiarybase = TDiaryBase
end

class WITDiary < tdiarybase
	def load_plugins
		super
	end

	def generate_wordindex(date,plugin,index)
		wordindex = WIWordIndex.new
		@io.transaction(date) do |diaries|
			wordindex.generate(diaries,plugin,index)
		end

		return wordindex
	end
end

class WIWordIndex
	def initialize
		@windex = {}
		@dates = []
	end

	def generate(diaries,plugin,index)
		diaries.each_value do |diary|
			num_section = 1
			diary.each_section do |section|
				anchor = index \
				       + plugin.anchor(diary.date.strftime("%Y%m%d")) \
				       + "#p%02d" % num_section
				if section.subtitle != nil
					scan(section.subtitle,anchor)
				end
				scan(section.body,anchor)
				num_section = num_section + 1
			end
		end
	end

	def load(dir)
		@windex = {}
		Dir.mkdir(dir) unless File.directory?(dir)
		PStore.new(dir + "/windex").transaction do |pstore|
			@dates = pstore.roots
			@dates.each do |key|
				windex_tmp = pstore[key]
				windex_tmp.each_key do |key_windex|
					if @windex.has_key?(key_windex) == false
						@windex[key_windex] = {"readname" => nil,
						                       "anchor" => []}
					end
					if @windex[key_windex]["readname"] == nil \
						&& windex_tmp[key_windex].has_key?("readname") == true
							@windex[key_windex]["readname"] = windex_tmp[key_windex]["readname"]
					end
					@windex[key_windex]["anchor"].concat(windex_tmp[key_windex]["anchor"])
				end
			end
		end
	end

	def save(dir,keyname)
		if File.directory?(dir) == false
			Dir.mkdir(dir,0755)
		end
		PStore.new(dir + "/windex").transaction do |pstore|
			pstore[keyname] = @windex
		end
	end

	def generate_html(page)
		return page.generate_html(@windex)
	end

	def has_key?(key)
		return @windex.has_key?(key)
	end

	def [](key)
		return @windex[key]
	end

private
	def scan(body,anchor)
		to_delimiter_end = {
			"(" => ")","[" => "]","{" => "}","<" => ">",
		}

		wistrs = body.scan(%r[<%\s*=\s*windex\s*[^(<%)]*\s*%>])
		wistrs.each do |wistr|
			# �������
			argstr = wistr.gsub(%r[<%\s*=\s*windex\s*],"")
			argstr = argstr.gsub(%r[\s*%>],"")
			args = []
			flag_done = false
			while flag_done == false
				pos_delimiter = argstr.index(%r['|"|%[Qq].]) #"'
				if pos_delimiter != nil
					# �ǥ�ߥ�ʸ������
					delimiter = argstr.scan(%r['|"|%[Qq].])[0] #"'
					if delimiter.length == 3
						delimiter_end = delimiter[2].chr
						if to_delimiter_end.has_key?(delimiter_end)
							delimiter_end = to_delimiter_end[delimiter_end]
						end
					else
						delimiter_end = delimiter
					end

					# �ǥ�ߥ��ޤǤ�ʸ�������
					argstr = argstr[(pos_delimiter + delimiter.length)..-1]
					pos_delimiter = argstr.index(delimiter_end)
					if pos_delimiter != nil
						if pos_delimiter > 0
							# �����Ȥ��Ƽ���
							args << argstr[0..(pos_delimiter - 1)]
						else
							args << ""
						end
						# �ǥ�ߥ��ޤǤ�ʸ�������
						argstr = argstr[(pos_delimiter + delimiter_end.length)..-1]
					else
						flag_done = true
					end
				else
					flag_done = true
				end
			end

			if args.length > 0
				if @windex.has_key?(args[0]) == false
					# �ϥå��������
					@windex[args[0]] = {"readname" => nil,"anchor" => []}
				end
				if args.length > 1 && @windex[args[0]]["readname"] == nil && args[1] != ""
					@windex[args[0]]["readname"] = args[1]
				end
				@windex[args[0]]["anchor"] << anchor
			end
		end
	end
end

class WIIndexPage
	def initialize(title,css)
		@title = title
		@css = css
	end

	def generate_html(windex)
		body = ""

		# �����̾ => ̾�������� �Υϥå��������
		subindex_to_name = {}
		windex.keys.each do |key|
			subindex = ""
			if windex[key]["readname"] != nil
				subindex = get_subindex(windex[key]["readname"])
			else
				subindex = get_subindex(key)
			end
			if subindex_to_name.has_key?(subindex) == false
				subindex_to_name[subindex] = []
			end
			subindex_to_name[subindex] << key
		end

		# �����̾���Ȥ�HTML������
		if subindex_to_name.has_key?("����") == true
			body << generate_html_subindex(windex,subindex_to_name,"����")
		end
		subindex_to_name.keys.sort.each do |key|
			if key != "����"
				body << generate_html_subindex(windex,subindex_to_name,key)
			end
		end

		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{@title}(����)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [����]</h1>
					<div class="day"><div class="body">
						#{body}
					</div></div>
				</body>
			</html>
			BODY

		return body
	end

private
	def generate_html_subindex(windex,subindex_to_name,key)
		readname_to_name = {}
		subindex_to_name[key].each do |name|
			key_new = ""
			if windex[name]["readname"] != nil
				key_new = windex[name]["readname"]
			else
				key_new = name
			end
			if readname_to_name.has_key?(key_new) == false
				readname_to_name[key_new] = []
			end
			readname_to_name[key_new] << name
		end

		body = %Q[<div class="section"><h2>#{key}</h2>\n]

		# �ɤ߲�̾�Υ����Ȥǥ롼�� -> ̾���Υ����Ȥǥ롼��
		keys = readname_to_name.keys
		if keys.empty? == false
			keys.sort.each do |readname|
				readname_to_name[readname].sort.each do |name|
					body << "<p>#{name} ... "
					num_anchor = 1
					windex[name]["anchor"].sort.each do |anchor|
						body = body + %Q[<a href="#{anchor}">#{num_anchor}</a>]
						if num_anchor < windex[name]["anchor"].length
							body = body + ","
						end
						num_anchor = num_anchor + 1
					end
					body << "</p>"
				end
			end
		end
		body << "\n</div>\n"

		return body
	end

	def get_subindex(name)
		to_plainhiragana = {
			"��" => "��","��" => "��","��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��",
			"��" => "��","��" => "��","��" => "��","��" => "��",
		}
		to_1byte = {
			"��" => "!",'��' => '"',"��" => "#","��" => "$","��" => "%","��" => "&","��" => "'","��" => "(","��" => ")","��" => "*","��" => "+","��" => ",","��" => "-","��" => ".","��" => "/",
			"��" => "0","��" => "1","��" => "2","��" => "3","��" => "4","��" => "5","��" => "6","��" => "7","��" => "8","��" => "9","��" => ":","��" => ";","��" => "<","��" => "=","��" => ">","��" => "?",
			"��" => "@","��" => "A","��" => "B","��" => "C","��" => "D","��" => "E","��" => "F","��" => "G","��" => "H","��" => "I","��" => "J","��" => "K","��" => "L","��" => "M","��" => "N","��" => "O",
			"��" => "P","��" => "Q","��" => "R","��" => "S","��" => "T","��" => "U","��" => "V","��" => "W","��" => "X","��" => "Y","��" => "Z","��" => "[","��" => "\\","��" => "]","��" => "^","��" => "_",
			"��" => "a","��" => "b","��" => "c","��" => "d","��" => "e","��" => "f","��" => "g","��" => "h","��" => "i","��" => "j","��" => "k","��" => "l","��" => "m","��" => "n","��" => "o",
			"��" => "p","��" => "q","��" => "r","��" => "s","��" => "t","��" => "u","��" => "v","��" => "w","��" => "x","��" => "y","��" => "z","��" => "{","��" => "|","��" => "}","��" => "~",
		}

		topchr = name[0,1]
		if topchr.count("\xA1-\xFE") == 1
			# 2�Х���ʸ��
			topchr = name[0,2]
		end
		if to_1byte.has_key?(topchr) == true
			topchr = to_1byte[topchr]
		end
		if topchr.length == 1
			# 1�Х���ʸ���ν���
			topchr = topchr.upcase
			
			if (0x21 <= topchr[0] && topchr[0] <= 0x2F) \
				|| (0x3A <= topchr[0] && topchr[0] <= 0x40) \
				|| (0x5B <= topchr[0] && topchr[0] <= 0x60) \
				|| (0x7B <= topchr[0] && topchr[0] <= 0x7B)
					topchr = "����"
			end
		else
			# 2�Х���ʸ���ν���
			# ��������->�Ҥ餬���Ѵ�
			code = topchr[0] * 0x100 + topchr[1]
			if 0xA5A1 <= code && code <= 0xA5F3
				topchr = 0xA4.chr + topchr[1].chr
			end

			# ���� / Ⱦ���� �����ʤ��Ѵ�
			if to_plainhiragana.has_key?(topchr) == true
				topchr = to_plainhiragana[topchr]
			end
		end

		return topchr
	end
end

class WIRedirectPage
	def initialize(key)
		@key = key
	end

	def generate_html(windex)
		anchor = windex[@key]["anchor"][0]
		body = <<-BODY
			<html>
				<head>
					<meta http-equiv="refresh" content="0;url=#{anchor}">
					<title>moving...</title>
				</head>
				<body>Wait or <a href="#{anchor}">Click here!</a></body>
			</html>
			BODY

		return body
	end
end

class WISinglePage
	def initialize(title,date_format,css,key)
		@title = title
		@date_format = date_format
		@css = css
		@key = key
	end

	def generate_html(windex)
		anchors = windex[@key]["anchor"]
		body = %Q[<div class="section"><h2>#{@key}</h2>\n]
		anchors.sort.each do |anchor|
			str_date = anchor.scan(/\d{8}/)[0]
			date = Time.local(str_date[0..3].to_i,str_date[4..5].to_i,str_date[6..7].to_i)
			body << %Q[<p><a href="#{anchor}">#{date.strftime(@date_format)}</a></p>\n]
		end
		body << "\n</div>\n"
		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{@title}(����)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [����]</h1>
					<div class="day"><div class="body">
						#{body}
					</div></div>
				</body>
			</html>
			BODY

		return body
	end
end

class WIErrorPage
	def initialize(title,css,key)
		@title = title
		@css = css
		@key = key
	end

	def generate_html(windex)
		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{@title}(����)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [����]</h1>
					<div class="day"><div class="body">
						������ɡ�#{@key}�פ���Ͽ����Ƥ��ޤ���
					</div></div>
				</body>
			</html>
			BODY

		return body
	end
end

def windex(str,readname = "")
	return str
end

def wikw(str)
	if @wordindex.has_key?(str) == true
		anchors = @wordindex[str]["anchor"]
		if anchors.length == 1
			return %Q[<a href="#{anchors[0]}">#{str}</a>]
		else
			body = "#{str}("
			num_anchor = 1
			anchors.sort.each do |anchor|
				body << %Q[<a href="#{anchor}">#{num_anchor}</a>]
				if num_anchor < anchors.length
					body << ","
				end
				num_anchor = num_anchor + 1
			end
			body << ")"

			return body
		end
	end

	return str
end

if mode != "CGI"
	@wordindex = WIWordIndex.new
	@wordindex.load(@cache_path + "/windex")

	add_update_proc do
		if @conf.options["windex.generate_all"] == true
			tdiary = WITDiary.new(@cgi,"day.rhtml",@conf)
			@years.each_key do |year|
				@years[year.to_s].each do |month|
					date = Time::local(year,month)
					wordindex = tdiary.generate_wordindex(date,self,@conf.index)
					wordindex.save(@cache_path + "/windex",date.strftime('%Y%m'))
				end
			end
		else
			wordindex = WIWordIndex.new
			wordindex.generate(@diaries,self,@conf.index)
			wordindex.save(@cache_path + "/windex",@date.strftime('%Y%m'))
		end
	end
else
	cgi = CGI.new
	conf = TDiary::Config.new
	cache_path = conf.data_path + "cache"
	plugin = WITDiary.new(cgi,"day.rhtml",conf).load_plugins

	wordindex = WIWordIndex.new
	wordindex.load(cache_path + "/windex")
	if cgi.valid?('kw') == true
		key = cgi.params['kw'][0]
		if wordindex.has_key?(key) == true
			num_anchor = wordindex[key]["anchor"].length
			if num_anchor == 0
				page = WIErrorPage.new(conf.html_title,plugin.css_tag,key)
			elsif num_anchor == 1
				page = WIRedirectPage.new(key)
			else
				page = WISinglePage.new(conf.html_title,conf.date_format,plugin.css_tag,key)
			end
		else
			page = WIErrorPage.new(conf.html_title,plugin.css_tag,key)
		end
	else
		page = WIIndexPage.new(conf.html_title,plugin.css_tag)
	end
	body = wordindex.generate_html(page)

	header = {
		"type" => "text/html",
		"charset" => "EUC-JP",
		"Content-Length" => body.size.to_s,
		"Pragma" => "no-cache",
		"Cache-Control" => "no-cache",
		"Vary" => "User-Agent",
	}
	head = cgi.header(header)

	print head
	print body
end
