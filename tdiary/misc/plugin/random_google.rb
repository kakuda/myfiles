# random_google.rb $Revision: 1.4 $
#
# random_google: ����������������Ф���ñ���google�Ǹ��������󥯤���������
#
# �Ȥ���:
#   tDiary1.5.5�ʹߤ�Ƴ�����줿conf_proc���б����Ƥ���Τǡ�tDiary��������̤���ɤ�����
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

def random_google_pickup_word(date)
	analyzer = @conf['random_google.analyzer']
	analyzer = @conf['random_google.analyzer_path'] if analyzer == "user_defined"
	analyzer = "internal" if analyzer == ""
	if analyzer == "internal"
		m = self.methods
		url_regexp = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		@diaries[date.strftime('%Y%m%d')].to_src.
			gsub(url_regexp, '').
			scan(/(?:[��-��]{2,}|[��-����]{2,}|[0-9A-Za-z]{2,})/).sort.uniq.reject {|i| m.include?(i)}
	else
		require 'open3'
		inn, out, err = Open3.popen3("#{analyzer} | sort | uniq")
		inn.puts @diaries[date.strftime('%Y%m%d')].to_src
		inn.close
		m = self.methods
		r = out.read.map do |l|
			word = l.split[0]
			if /\s(̾��|̤�θ�)/.match(l) and
				!/(\W|\d)/.match(word) and            # ����Ȥ��������פ�ʤ�
				!/\A[��-��]{1,2}\z/.match(word) and   # 2ʸ���ʲ��ΤҤ餬�ʤ��פ��Ǥ���
				!m.include?(word)          # Plugin�Υ᥽�åɤϽ�������������������
				word
			else
				nil
			end
		end.compact
		out.close
		err.close
		r
	end
end

def random_google_init
	@conf['random_google.n'] ||= 2
	@conf['random_google.caption'] ||= '�⤷���������Ϣ���뤫�⤷��ʤ��ڡ���'
	@conf['random_google.popup'] ||= '�����Τ���: $1'
	@conf['random_google.append'] ||= ''
	@conf['random_google.exception'] ||= ''
	if @conf.secure
		@conf['random_google.analyzer'] = "internal"
	else
		@conf['random_google.analyzer'] ||= "internal"
		@conf['random_google.analyzer_path'] ||= ""
	end
end

if /(latest|day)/ === @mode and ! @conf.bot? and ! @conf.mobile_agent?
	add_body_enter_proc do |date|
		random_google_init

		exception = @conf['random_google.exception'].split
		words = random_google_pickup_word(date) - exception
		if words.empty?
			''
		else
			r = []
			@conf['random_google.n'].times do |i|
				r << words.delete_at(rand(words.size))
			end
			append = @conf['random_google.append'].split
			rr = (r.compact.map {|i| CGI::escape(i)} + append).join('+')
			rrr = r.compact.map {|i| CGI::escapeHTML(i)}.join(' ')
			caption = @conf['random_google.caption'].gsub(/\$1/, rrr)
			popup = @conf['random_google.popup'].gsub(/\$1/, rrr)
			<<-HTML
			<div class="body-enter">
			[<a href="http://www.google.com/search?lr=lang_ja&amp;ie=euc-jp&amp;q=#{rr}" title="#{popup}">
			#{caption}
			</a>]
			</div>
			HTML
		end
	end
end

def saveconf_random_google
	if @mode == 'saveconf' then
		@conf['random_google.n'] = @cgi.params['random_google_n'][0].to_i
		@conf['random_google.caption'] = @cgi.params['random_google_caption'][0]
		@conf['random_google.popup'] = @cgi.params['random_google_popup'][0]
		@conf['random_google.append'] = @cgi.params['random_google_append'][0]
		@conf['random_google.exception'] = @cgi.params['random_google_exception'][0]
		if @conf.secure
			@conf['random_google.analyzer'] = "internal"
		else
			@conf['random_google.analyzer'] = @cgi.params['random_google_analyzer'][0]
			@conf['random_google.analyzer_path'] = @cgi.params['random_google_analyzer_path'][0]
		end
	end
end

add_conf_proc('RandomGoogle', '��Ϣ���뤫�⤷��ʤ��ڡ�������') do
	saveconf_random_google
	random_google_init

	r = <<-HTML
	<h3 class="subtitle">������ɤο�</h3>
	#{"<p>������ʸ������Ф��륭����ɤο�</p>" unless @conf.mobile_agent?}
	<p><select name="random_google_n">
	HTML

	1.upto(9) do |i|
		r << %Q|		<option value="#{i}"#{@conf['random_google.n'] == i ? " selected" : ""}>#{i}</option>\n|
	end
	r << <<-HTML
	</select></p>

	<h3 class="subtitle">ɽ����Ϣ</h3>
	#{"<p>google�ؤΥ�󥯤򼨤�ʸ����ȥ�󥯤ξ�˥ޥ����ݥ��󥿤��֤������˥ݥåץ��åפ���ʸ�������ꤷ�ޤ���ʸ������� $1 ����Ф��줿������ɤ��ִ�����ޤ���</p>" unless @conf.mobile_agent?}
	<p>��󥯡�<input name="random_google_caption" size="70" value="#{@conf['random_google.caption']}"></p>
	<p>�ݥåץ��åס�<input name="random_google_popup" size="70" value="#{@conf['random_google.popup']}"></p>

	<h3 class="subtitle">�ɲä��륭�����</h3>
	#{"<p>�ɲä�����������ɤ���ꤷ�ޤ���ʣ�����ꤹ����ϥ�����ɤ򥹥ڡ����Ƕ��ڤäƻ��ꤷ�Ƥ���������</p>" unless @conf.mobile_agent?}
	#{"<p>��)</p><pre>-site:example.com</pre>" unless @conf.mobile_agent?}
	<p><input name="random_google_append" size="70" value="#{@conf['random_google.append']}"></p>

	<h3 class="subtitle">�������륭�����</h3>
	#{"<p>����������������ɤ���ꤷ�ޤ���ʣ�����ꤹ����ϥ�����ɤ򥹥ڡ����Ƕ��ڤäƻ��ꤷ�Ƥ���������</p>" unless @conf.mobile_agent?}
	#{"<p>��)</p><pre>a the</pre>" unless @conf.mobile_agent?}
	<p><input name="random_google_exception" size="70" value="#{@conf['random_google.exception']}"></p>
	HTML

	unless @conf.secure
		r << <<-HTML
	<h3 class="subtitle">�����ǲ��ϴ������</h3>
	#{"<p>������ɤ���Ф˷����ǲ��ϴ�����Ѥ��뤫�ɤ�������ꤷ�ޤ��������ǲ��ϴ����Ѥ��ʤ�����/([��-��]{2,}|[��-����]{2,}|[0-9A-Za-z]{2,})/�Ȥ�������ɽ���ǥ�����ɤ���Ф��ޤ��������ޤ����٤Ϥ褯����ޤ���</p>" unless @conf.mobile_agent?}
	#{"<p>Chasen��MeCab��ɸ��ѥ��˥��󥹥ȡ��뤵��Ƥ��ʤ����ϡ־�����ꤹ��פ����򤷡����Ρַ����ǲ��ϴ�Υѥ��פǷ����ǲ��ϴ�����Хѥ��ǻ��ꤷ�Ʋ�������</p>" unless @conf.mobile_agent?}
	#{"<p>Chasen��MeCab�ʳ��η����ǲ��ϴ�����Ѥ���������Ʊ�ͤˡ־�����ꤹ��פ����򤷡����Ρַ����ǲ��ϴ�Υѥ��פǷ����ǲ��ϴ�����Хѥ��ǻ��ꤷ�Ʋ��������ǽ�Υ����˷����Ǥ����Ϥ��졤����Ʊ���Ԥˤ��η����Ǥ��ʻ�(��̾�����)�����Ϥ����褦�ʷ����ǲ��ϴ�Ǥ�������Ѳ�ǽ�Ǥ���</p>" unless @conf.mobile_agent?}
	<p><select name="random_google_analyzer">
		<option value="chasen"#{@conf['random_google.analyzer'] == "chasen" ? " selected" : ""}>ChaSen�����Ѥ���</option>
		<option value="mecab"#{@conf['random_google.analyzer'] == "mecab" ? " selected" : ""}>MeCab�����Ѥ���</option>
		<option value="user_defined"#{@conf['random_google.analyzer'] == "user_defined" ? " selected" : ""}>������ꤹ��</option>
		<option value="internal"#{@conf['random_google.analyzer'] == "internal" ? " selected" : ""}>���Ѥ��ʤ�</option>
 	</select></p>

	<h3 class="subtitle">�����ǲ��ϴ�Υѥ�</h3>
	#{"<p>���Ѥ�������ǲ��ϴ�����Хѥ��ǻ��ꤷ�ޤ���</p>" unless @conf.mobile_agent?}
	#{"<p>��)</p><pre>/usr/local/bin/chasen</pre>" unless @conf.mobile_agent?}
	<p><input name="random_google_analyzer_path" size="70" value="#{@conf['random_google.analyzer_path']}"></p>
	HTML
	end
	r
end

# vim: ts=3
