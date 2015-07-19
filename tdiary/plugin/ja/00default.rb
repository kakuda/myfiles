#
# ja/00default.rb: Japanese resources of 00default.rb.
#

#
# header
#
def title_tag
	r = "<title>#{CGI::escapeHTML( @html_title )}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(�ɵ�)'
	when 'edit'
		r << '(�Խ�)'
	when 'preview'
		r << '(�ץ�ӥ塼)'
	when 'showcomment'
		r << '(�ѹ���λ)'
	when 'conf'
		r << '(����)'
	when 'saveconf'
		r << '(���괰λ)'
	when 'nyear'
		years = @diaries.keys.map {|ymd| ymd.sub(/^\d{4}/, "")}
		r << "(#{@cgi.params['date'][0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label @date, years}])" if @date
	end
	r << '</title>'
end

#
# TSUKKOMI mail
#
def comment_mail_mime( str )
	require 'nkf'
	NKF::nkf( "-j -m0 -f50", str ).collect do |s|
		%Q|=?ISO-2022-JP?B?#{[s.chomp].pack( 'm' ).gsub( /\n/, '' )}?=|
	end
end

def comment_mail_conf_label; '�ĥå��ߥ᡼��'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']

	<<-HTML
	<h3 class="subtitle">�ĥå��ߥ᡼�������</h3>
	#{"<p>�ĥå��ߤ����ä����ˡ��᡼������뤫�ɤ��������򤷤ޤ���</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{if @conf['comment_mail.enable'] then " selected" end}>����</option>
        <option value="false"#{if not @conf['comment_mail.enable'] then " selected" end}>����ʤ�</option>
	</select></p>
	<h3 class="subtitle">������</h3>
	#{"<p>�᡼������������ꤷ�ޤ���1�Ԥ�1�᡼�륢�ɥ쥹�η��ǡ�ʣ�������ǽ�Ǥ�������Τʤ����ˤϡ����ʤ��Υ᡼�륢�ɥ쥹�������ޤ���</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{CGI::escapeHTML( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">�᡼��إå�</h3>
	#{"<p>�᡼���Subject�ˤĤ���إå�ʸ�������ꤷ�ޤ�������ʬ�����������ʤ褦�˻��ꤷ�ޤ����ºݤ�Subject�ˤϡֻ���ʸ����:����-1�פΤ褦�ˡ����դȥ������ֹ椬�դ��ޤ�������������ʸ������ˡ�%��³���ѻ������ä���硢��������եե����ޥåȻ���򸫤ʤ��ޤ����Ĥޤ�����աפ���ʬ�ϼ�ưŪ���ղä���ʤ��ʤ�ޤ�(�������ֹ���ղä���ޤ�)��</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{CGI::escapeHTML( @conf['comment_mail.header'])}"></p>
	HTML
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/ja/?#{@conf.style}%A5%B9%A5%BF%A5%A4%A5%EB">����</a>|
end

#
# labels (normal)
#
def no_diary; "#{@date.strftime( @conf.date_format )}�������Ϥ���ޤ���"; end
def comment_today; '�����Υĥå���'; end
def comment_total( total ); "(��#{total}��)"; end
def comment_new; '�ĥå��ߤ������'; end
def comment_description; '�ĥå��ߡ������Ȥ�����Фɤ���! E-mail���ɥ쥹�ϸ�������ޤ���'; end
def comment_description_short; '�ĥå���!!'; end
def comment_name_label; '��̾��'; end
def comment_name_label_short; '̾��'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; '������'; end
def comment_body_label_short; '��ʸ'; end
def comment_submit_label; '���'; end
def comment_submit_label_short; '���'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def referer_today; '�����Υ�󥯸�'; end
def trackback_today; '������TrackBacks'; end
def trackback_total( total ); "(��#{total}��)"; end

def navi_index; '�ȥå�'; end
def navi_latest; '�ǿ�'; end
def navi_oldest; '�Ǹ�'; end
def navi_update; "�ɵ�"; end
def navi_edit; "�Խ�"; end
def navi_preference; "����"; end
def navi_prev_diary(date); "��������(#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "��������(#{date.strftime(@date_format)})"; end
def navi_prev_nyear(date); "������(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "������(#{date.strftime('%m-%d')})"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'�ɵ�'
	else
		'��Ͽ'
	end
end
def preview_label; '�ץ�ӥ塼'; end

def label_no_referer; '��󥯸���Ͽ�����ꥹ��'; end
def label_referer_table; '����ִ��ꥹ��'; end

def nyear_diary_label(date, years); "Ĺǯ����"; end
def nyear_diary_title(date, years); "Ĺǯ����"; end

#
# labels (for mobile)
#
def mobile_navi_latest; '�ǿ�'; end
def mobile_navi_update; "�ɵ�"; end
def mobile_navi_preference; "����"; end
def mobile_navi_prev_diary; "��"; end
def mobile_navi_next_diary; "��"; end
def mobile_label_hidden_diary; '�������ϡ���ɽ���ۤǤ�'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences (resources)
#
add_conf_proc( 'default', '����' ) do
	saveconf_default
	<<-HTML
	<h3 class="subtitle">����̾</h3>
	#{"<p>���ʤ���̾������ꤷ�ޤ���HTML�إå����Ÿ������ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{CGI::escapeHTML @conf.author_name}" size="40"></p>
	<h3 class="subtitle">�᡼�륢�ɥ쥹</h3>
	#{"<p>���ʤ��Υ᡼�륢�ɥ쥹����ꤷ�ޤ���HTML�إå����Ÿ������ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{@conf.author_mail}" size="40"></p>
	<h3 class="subtitle">�ȥåץڡ���URL</h3>
	#{"<p>���������̤Υ���ƥ�Ĥ�����л��ꤷ�ޤ���¸�ߤ��ʤ����ϲ������Ϥ��ʤ��Ƥ��ޤ��ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{@conf.index_page}" size="50"></p>
	<h3 class="subtitle">����Ĵ��</h3>
	#{"<p>���������ե������������������դ����ñ�̤�Ĵ���Ǥ��ޤ����㤨�и���2���ޤǤ������Ȥ��ư����������ˤϡ�-2�פΤ褦�˻��ꤹ�뤳�Ȥǡ�2����ʬ�����줿���դ����������褦�ˤʤ�ޤ����ޤ����������դ�Web�����о�λ���ˤʤäƤ���Τǡ������Υ����ФǱ��Ĥ��Ƥ�����λ���Ĵ���ˤ����ѤǤ��ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{@conf.hour_offset}" size="5"></p>
	HTML
end

add_conf_proc( 'header', '�إå����եå�' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">�����ȥ�</h3>
	#{"<p>HTML��&lt;title&gt;�����椪��ӡ���Х���ü������λ��Ȼ��˻Ȥ��륿���ȥ�Ǥ���HTML�����ϻȤ��ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{ CGI::escapeHTML @conf.html_title }" size="50"></p>
	<h3 class="subtitle">�إå�</h3>
	#{"<p>��������Ƭ�����������ʸ�Ϥ���ꤷ�ޤ���HTML�������Ȥ��ޤ�����&lt;%=navi%&gt;�פǡ��ʥӥ��������ܥ���������Ǥ��ޤ�(���줬�ʤ��ȹ������Ǥ��ʤ��ʤ�ΤǺ�����ʤ��褦�ˤ��Ƥ�������)���ޤ�����&lt;%=calendar%&gt;�פǥ��������������Ǥ��ޤ�������¾���Ƽ�ץ饰����򵭽ҤǤ��ޤ���</p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{ CGI::escapeHTML @conf.header }</textarea></p>
	<h3 class="subtitle">�եå�</h3>
	#{"<p>�����κǸ�����������ʸ�Ϥ���ꤷ�ޤ����إå���Ʊ�ͤ˻���Ǥ��ޤ���</p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{ CGI::escapeHTML @conf.footer }</textarea></p>
	HTML
end

add_conf_proc( 'display', 'ɽ������' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">��������󥢥󥫡�</h3>
	#{"<p>�����Υ�����������Ƭ(���֥����ȥ�ι�Ƭ)����������롢����ѤΥ��󥫡�ʸ�������ꤷ�ޤ����ʤ���&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;�פ���ꤹ��ȡ��ơ��ޤˤ�äƤϼ�ưŪ�˲������󥫡����Ĥ��褦�ˤʤ�ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{ CGI::escapeHTML @conf.section_anchor }" size="40"></p>
	<h3 class="subtitle">�ĥå��ߥ��󥫡�</h3>
	#{"<p>�ɼԤ���Υĥå��ߤ���Ƭ����������롢����ѤΥ��󥫡�ʸ�������ꤷ�ޤ����ʤ���&lt;span class=\"canchor\"&gt;_&lt;/span&gt;�פ���ꤹ��ȡ��ơ��ޤˤ�äƤϼ�ưŪ�˲������󥫡����Ĥ��褦�ˤʤ�ޤ���</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{ CGI::escapeHTML @conf.comment_anchor }" size="40"></p>
	<h3 class="subtitle">���եե����ޥå�</h3>
	#{"<p>���դ�ɽ����ʬ�˻Ȥ���ե����ޥåȤ���ꤷ�ޤ���Ǥ�դ�ʸ�����Ȥ��ޤ�������%�פǻϤޤ�ѻ��ˤϼ��Τ褦���ü�ʰ�̣������ޤ�����%Y��(����ǯ)����%m��(�����)����%b��(û��̾)����%B��(Ĺ��̾)����%d��(��)����%a��(û����̾)����%A��(Ĺ����̾)��</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{ CGI::escapeHTML @conf.date_format }" size="30"></p>
	<h3 class="subtitle">�ǿ�ɽ���κ�������</h3>
	#{"<p>�ǿ���������ɽ������Ȥ��ˡ����Υڡ�����˲���ʬ��������ɽ�����뤫����ꤷ�ޤ���</p>" unless @conf.mobile_agent?}
	<p>����<input name="latest_limit" value="#{ @conf.latest_limit }" size="2">��ʬ</p>
	<h3 class="subtitle">Ĺǯ������ɽ��</h3>
	#{"<p>Ĺǯ������ɽ�����뤿��Υ�󥯤�ɽ�����뤫�ɤ�������ꤷ�ޤ���</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{if @conf.show_nyear then " selected" end}>ɽ��</option>
        <option value="false"#{if not @conf.show_nyear then " selected" end}>��ɽ��</option>
	</select></p>
	HTML
end

@theme_location_comment = "<p>�����ˤʤ��ơ��ޤ�<a href=\"http://www.tdiary.org/20021001.html\">�ơ��ޡ������꡼</a>��������Ǥ��ޤ���</p>"

add_conf_proc( 'theme', '�ơ���' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">�ơ��ޤλ���</h3>
	#{"<p>�����Υǥ������ơ��ޡ��⤷����CSS��ľ�����Ϥǻ��ꤷ�ޤ����ɥ�åץ������˥塼�����CSS���ꢪ�פ����򤷤����ˤϡ��������CSS��URL�����Ϥ��Ƥ���������</p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme">
		<option value="">CSS���ꢪ</option>
	HTML
	@conf_theme_list.each do |theme|
		r << %Q|<option value="#{theme[0]}"#{if theme[0] == @conf.theme then " selected" end}>#{theme[1]}</option>|
	end
	r << <<-HTML
	</select>
	<input name="css" size="50" value="#{ @conf.css }">
	</p>
	#{@theme_location_comment unless @conf.mobile_agent?}
	HTML
end

add_conf_proc( 'comment', '�ĥå���' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">�ĥå��ߤ�ɽ��</h3>
	#{"<p>�ɼԤ���Υĥå��ߤ�ɽ�����뤫�ɤ�������ꤷ�ޤ���</p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{if @conf.show_comment then " selected" end}>ɽ��</option>
		<option value="false"#{if not @conf.show_comment then " selected" end}>��ɽ��</option>
	</select></p>
	<h3 class="subtitle">�ĥå��ߥꥹ��ɽ����</h3>
	#{"<p>�ǿ��⤷���Ϸ���ɽ������ɽ�����롢�ĥå��ߤκ���������ꤷ�ޤ����ʤ�������ɽ�����ˤϤ����λ���ˤ�����餺���٤ƤΥĥå��ߤ�ɽ������ޤ���</p>" unless @conf.mobile_agent?}
	<p>����<input name="comment_limit" value="#{ @conf.comment_limit }" size="3">��</p>
	HTML
end

add_conf_proc( 'referer', '��󥯸�' ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">��󥯸���ɽ��</h3>
	#{"<p>��󥯸��ꥹ�Ȥ�ɽ�����뤫�ɤ�������ꤷ�ޤ���</p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{if @conf.show_referer then " selected" end}>ɽ��</option>
		<option value="false"#{if not @conf.show_referer then " selected" end}>��ɽ��</option>
	</select></p>
	<h3 class="subtitle">��󥯸��ꥹ��ɽ����</h3>
	#{"<p>�ǿ��⤷���Ϸ���ɽ������ɽ�����롢��󥯸��ꥹ�Ȥκ���������ꤷ�ޤ����ʤ�������ɽ�����ˤϤ����λ���ˤ�����餺���٤ƤΥ�󥯸���ɽ������ޤ���</p>" unless @conf.mobile_agent?}
	<p>����<input name="referer_limit" value="#{@conf.referer_limit}" size="3">������</p>
	<h3 class="subtitle">��󥯸��ε�Ͽ����</h3>
	#{"<p>���ջ���Υ����������Υ�󥯸�������Ͽ���뤫�ɤ�������ꤷ�ޤ������λ���򤹤�ȥ���ƥʤ��󥯽�����ξ��󤬵�Ͽ����ʤ��ʤ�Τǡ���󥯸��ΥΥ������������ޤ���</p>" unless @conf.mobile_agent?}
	<p><select name="referer_day_only">
		<option value="true"#{if @conf.referer_day_only then " selected" end}>���ջ�����Υ��������Τߵ�Ͽ����</option>
		<option value="false"#{if not @conf.referer_day_only then " selected" end}>���٤ƤΥ��������ǵ�Ͽ����</option>
	</select></p>
	<h3 class="subtitle">��󥯸���Ͽ�����ꥹ��</h3>
	#{"<p>��󥯸��ꥹ�Ȥ��ɲä��ʤ�URL����ꤷ�ޤ�������ɽ���ǻ���Ǥ��ޤ���1��1�Ԥ����Ϥ��Ƥ���������</p>" unless @conf.mobile_agent?}
	<p>��<a href="#{@conf.update}?referer=no" target="referer">��¸����Ϥ�����</a></p>
	<p><textarea name="no_referer" cols="70" rows="10">#{@conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">��󥯸��ִ��ꥹ��</h3>
	#{"<p>��󥯸��ꥹ�Ȥ�URL�������ʸ������Ѵ������б�ɽ�����Ǥ��ޤ���1��ˤĤ���URL��ɽ��ʸ��������Ƕ��ڤäƻ��ꤷ�ޤ�������ɽ�����Ȥ���Τǡ�URL��˸��줿��(��)�פϡ��ִ�ʸ������ǡ�\\1�פΤ褦�ʡ�\�����פ����ѤǤ��ޤ���</p>" unless @conf.mobile_agent?}
	<p>��<a href="#{@conf.update}?referer=table" target="referer">��¸����Ϥ�����</a></p>
	<p><textarea name="referer_table" cols="70" rows="10">#{@conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

add_conf_proc( 'csrf_protection', 'CSRF(��ü��)�к�' ) do
	err = saveconf_csrf_protection
	errstr = ''
	case err
	when :param
		errstr = '<p class="message">�������Ȥ߹�碌�Ǥ����ѹ�����ޤ���Ǥ�����</p>'
	when :key
		errstr = '<p class="message">�������Ǥ����ѹ�����ޤ���Ǥ�����</p>'
	end
	csrf_protection_method = @conf.options['csrf_protection_method'] || 1
	csrf_protection_key = @conf.options['csrf_protection_key'] || ''
	<<-HTML
	#{errstr}
	<p>���������ȡ��ꥯ�����ȥե���������(CSRF)���к���ˡ�����ꤷ�ޤ���</p>
	<p>CSRF����ϡ����դΤ���ʹ֤�Web�ڡ�����櫤�ųݤ��ޤ���
	����櫤�ųݤ����ڡ����򤢤ʤ�����������ȡ����ʤ��Υ֥饦����
	tDiary�˵��ν񤭹����׵�����Ф��Ƥ��ޤ��ޤ������ʤ��Υ֥饦����
	���׵�����Ф��Ƥ��ޤ����ᡢ�Ź沽���ѥ�����ݸ�����Ǥ��к��ˤʤ�ޤ���
	tDiary�Ǥϡ����μ�ι�����Ф��ơ���Referer�����å��פȡ�CSRF�����פȤ���
	2������ɱҼ��ʤ��Ѱդ��Ƥ��ޤ���</p>
	<div class="section">
	<h3 class="subtitle">Referer�����å��ˤ���ɱ�</h3>
	<h4>Referer���������θ���</h4>
	<p>#{if [0,1,2,3].include?(csrf_protection_method) then
            '<input type="checkbox" name="check_enabled2" value="true" checked disabled>
            <input type="hidden" name="check_enabled" value="true">'
          else
            '<input type="checkbox" name="check_enabled" value="true">'
        end}����(ɸ��)</input>
	</p>
	#{"<p>���ʤ��Υ֥饦�������Ф���Referer(��󥯸�����)�򸡺����ޤ���
	�񤭹����׵᤬�������ڡ����������Ф��줿���Ȥ��ǧ���뤳�Ȥǡ�
	���ڡ���������׵���ɤ��ޤ��������ʥڡ���������׵�򸡽Ф�����硢
	�����ꥯ�����Ȥ���ݤ��ޤ���
	����������̤Ǥϡ�̵���ˤ��뤳�ȤϽ���ޤ���</p>
	" unless @conf.mobile_agent?}
	<h4>Referer�����Ф��ʤ��֥饦�������</h4>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>����(ɸ��)</input>
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>���ʤ�</input>
	</p>
	#{"<p>�֥饦������Referer�������Ƥ��ʤ��ä�����ư�����ꤷ�ޤ���</p>
	<p>ɸ��Ǥϡ�Referer�����Ф���ʤ���硢�����ʥꥯ�����Ȥ�
	Ƚ�̤Ǥ��ʤ����ᡢ�񤭹��ߡ������ѹ�����ݤ��ޤ���
	���ʤ��Υ֥饦����Referer�����Ф��ʤ�����ξ�硢
	�������꤬�֤���פˤʤäƤ���ȡ������ν񤭹����׵����ݤ��Ƥ��ޤ��ޤ���
	�֥饦����������ѹ���Referer�����Ф���褦�ˤ��Ƥ���������
	�ɤ����Ƥ�Referer�����Ф�������˽���ʤ���硢�֤��ʤ��פˤ��Ƥ���������
	���ξ�硢Referer���������Ф���ʤ��ä����ˤ⡢
	�񤭹��ߡ������ѹ�������褦�ˤʤ�ޤ�����
	CSRF�ˤ�빶��ȶ��̤Ǥ��ʤ��ʤ�ޤ��Τǡ�ɬ�����Ρ�CSRF�ɻߥ����פ�
	�����ʻ�Ѥ��Ʋ�������</p>
	</div>
	" unless @conf.mobile_agent?}
	<div class="section">
	<h3 class="subtitle">CSRF�ɻߥ����ˤ���ɱ�</h3>
	<h4>CSRF�ɻߥ����θ���</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>����</input>
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>���ʤ�(ɸ��)</input>
	</p>
	#{"<p>�񤭹��ߥե�����˵����񤭹����ɻߤΤ���Υ��������ꤷ��CSRF���ɤ��ޤ���
	���ڡ�������̩�Υ������Τ�ʤ��¤ꡢ
	���ν񤭹����׵���������뤳�Ȥ��Ǥ��ʤ��ʤ�ޤ���
	���θ�����֤���פ����ꤹ���硢���θ������ꤷ�Ʋ�������
	��������ξ���֤��ʤ��פˤ��뤳�ȤϤǤ��ޤ���</p>
	<p>���������֤���פˤ�����硢���ε������б����Ƥ��ʤ�������
	�ץ饰����ư��ʤ��ʤ뤳�Ȥ�����ޤ���</p>
	" unless @conf.mobile_agent?}
	<h4>CSRF �ɻߥ���</h4>
	<p><input type="text" name="key" value="#{CGI::escapeHTML csrf_protection_key}" size="30"></p>
	#{"<p>�����ɻߥ��������ꤷ�ޤ�����¬���ˤ���Ŭ����ʸ�������ꤷ�Ʋ�������
	���θ��������˱̤��ȡ�CSRF�����������ǽ��������ޤ���
	¾�Υѥ���ɤȶ��ѤϤ��ƤϤ����ޤ��󡣤ʤ������ꤷ��ʸ����򤢤ʤ����Ф��Ƥ���ɬ�פϤ���ޤ���</p>" unless @conf.mobile_agent?}
	#{"<p class=\"message\">���: 
	���ʤ��Υ֥饦���ϸ���Referer�����Ф��Ƥ��ʤ��褦�Ǥ���
	<a href=\"#{@conf.update}?conf=csrf_protection\">���Υ�󥯤���⤦���
	���Υڡ����򳫤��ƤߤƲ�����</a>��
	����Ǥ⤳�Υ�å��������Ф�����Ǥϡ�����������Ѥ����硢
	���Ū��Referer�����Ф�������ˤ��뤫��
	ľ��tdiary.conf���Խ����Ʋ�������</p>
	</div>" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	HTML
end
