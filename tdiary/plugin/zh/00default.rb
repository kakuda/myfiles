#
# zh/00default.rb: Traditional-Chinese resources of 00default.rb.
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
		r << '(Append)'
	when 'edit'
		r << '(Edit)'
	when 'preview'
		r << '(Preview)'
	when 'showcomment'
		r << '(TSUKKOMI Status Change Completed)'
	when 'conf'
		r << '(Preferences)'
	when 'saveconf'
		r << '(Preferences Changed)'
	when 'nyear'
		years = @diaries.keys.map {|ymd| ymd.sub(/^\d{4}/, "")}
		r << "(#{years[0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label @date, years}])" if @date
	end
	r << '</title>'
end


#
# labels
#
def no_diary; "#{@date.strftime( @conf.date_format )} �o�ѨS���o���x"; end
def comment_today; "����j�T"; end
def comment_total( total ); "(�`�@��: #{total} �h)"; end
def comment_new; '�o��j�T'; end
def comment_description; '�w��o��z�糧�媺�j�T�A�z��g�� email ��}�u����x�D�H�i�H�ݨ��C'; end
def comment_description_short; '�o��j�T!!'; end
def comment_name_label; '�m�W'; end
def comment_name_label_short; '�m�W'; end
def comment_mail_label; '�q�l�l��'; end
def comment_mail_label_short; '�l��'; end
def comment_body_label; '�j�T'; end
def comment_body_label_short; '�j�T'; end
def comment_submit_label; '�o��'; end
def comment_submit_label_short; '�o��'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def referer_today; "�����嵲"; end
def trackback_today; "����ޥ�"; end
def trackback_total( total ); "(�`�@��: #{total} �h)"; end

def navi_index; '����'; end
def navi_latest; '�̷s��x'; end
def navi_oldest; '���¤�x'; end
def navi_update; "�s�W"; end
def navi_edit; "�s��"; end
def navi_preference; "�ﶵ�]�w"; end
def navi_prev_diary(date); "�e�@�h��x (#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "�U�@�h��x (#{date.strftime(@date_format)})"; end
def navi_prev_nyear(date); "�h�~��x (#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "���~��x (#{date.strftime('%m-%d')})"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'�s�W' #'Append'
	else
		'����' #'Replace'
	end
end
def preview_label; '�w��'; end #'Preview'

def label_no_referer; "�o�O���ѥ��C�X���嵲�C��"; end
def label_referer_table; "Today's Link Conversion Rule"; end

def nyear_diary_label(date, years); "���鱡�h"; end
def nyear_diary_title(date, years); "�L�h�����ɦ���"; end


#
# labels (for mobile)
#
def mobile_navi_latest; 'Latest'; end
def mobile_navi_update; 'Update'; end
def mobile_navi_preference; 'Prefs'; end
def mobile_navi_prev_diary; 'Prev'; end
def mobile_navi_next_diary; 'Next'; end
def mobile_label_hidden_diary; 'This day is HIDDEN.'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences
#

# basic (default)
add_conf_proc( 'default', '�򥻳]�w' ) do
	saveconf_default
	<<-HTML
	<h3 class="subtitle">�@��</h3>
	#{"<p>��W�z���j�W�a�I����쪺�ȱN�|�Φb HTML ���Y(header)�̡C</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{CGI::escapeHTML @conf.author_name}" size="40"></p>
	<h3 class="subtitle">�q�l�l��</h3>
	#{"<p>��J�z���q�l�l���}�A����쪺�ȱN�Φb HTML ���Y(header)�̡C</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{@conf.author_mail}" size="40"></p>
	<h3 class="subtitle">�z���޺���(����)�� URL</h3>
	#{"<p>�Y�z���ۤv��������}�A�i�H����b�U���C</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{@conf.index_page}" size="50"></p>
	<h3 class="subtitle">�ɶ��t���վ�</h3>
	#{"<p>�Y�O�z��s�F��x�A�z�i�H�z�L�����(��쬰�p��)�Ӱ��۰ʽվ�ɶ��t�C�Ҧp���A�z�Y�Q�n���w�b�M����I�ҵo����x�Q���O�Q�Ѫ���x�A�z�N�i�H�b�o�̶�J -2�CtDiary �|�ѦҦ��ƭȨӧP�w�o�g��x���o�����C </p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{@conf.hour_offset}" size="5"></p>
	HTML
end

# header/footer (header)
add_conf_proc( 'header', '���ܻP���}' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">�j���D</h3>
	#{"<p>�o�O�z��x���j���D�A�z��J���ȷ|�Φb HTML �� &lt;title&gt; ���ط��C�S�O�`�N�A�����ФŨϥ� HTML ����(tags)�C </p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{ CGI::escapeHTML @conf.html_title }" size="50"></p>
	<h3 class="subtitle">����</h3>
	#{"<p>�o�q��r�N�|�\�m�b�C�ӭ��������ݡA�z�i�H�ϥ� HTML �y�k�C���O�ФŲ��� \"&lt;%=navi%&gt;\"���ҡA�]�����N��]�t\"��s\"(Update)�\\��s�b�����u�����C�v�A�� \"&lt;%=calendar%&gt;\" ���ҥN����C���B�z�]�i�H�ۥѷf�t�䥦�� plugin�C </p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{ CGI::escapeHTML @conf.header }</textarea></p>
	<h3 class="subtitle">���}</h3>
	#{"<p>�o�q��r���F������m�O�m�󩳺ݥH�~�A��l���p�P���ܡC </p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{ CGI::escapeHTML @conf.footer }</textarea></p>
	HTML
end

# diaplay
add_conf_proc( 'display', '���' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">�q�������I(anchor)�N��O��</h3>
	#{"<p>\"���I\" ���N�q�b�����䥦�����i�H�P�z����x���۳s���C�q�����I�|�Q�m��C�Ӭq�����}�Y�B�A�z�i�H���w \"&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;\"�A�ӹϧΤ����I�����L�A�|�ѧG���D�D���]�p�ӨM�w�C </p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{ CGI::escapeHTML @conf.section_anchor }" size="40"></p>
	<h3 class="subtitle">�j�T�����I(anchor)�N��O��</h3>
	#{"<p>�j�T�����I�|�m��C�h�j�T���}�Y�B�A�z�i�H���w \"&lt;span class=\"canchor\"&gt;_&lt;/span&gt;\"�C</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{ CGI::escapeHTML @conf.comment_anchor }" size="40"></p>
	<h3 class="subtitle">������榡</h3>
	#{"<p>������榡�A�@���z���w�U�C�o�� % �Ÿ�����f�t���r���A��զX�N�i�N�����榡�A�p \"%Y\"(�~), \"%m\"(��)��\"%b\"(�����²�u��ܪk), \"%B\"(���������ܪk), \"%d\"(��), \"%a\"(�P����²�u��ܪk), \"%A\"(�P��������ܪk)�C</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{ CGI::escapeHTML @conf.date_format }" size="30"></p>
	<h3 class="subtitle">�u�̷s��x�v�̦h�n�q�X�X�ѥ��H</h3>
	#{"<p>�b�u�̷s��x�v���A�z�n��ܦh�֤ѥ�����x�H </p>" unless @conf.mobile_agent?}
	<p><input name="latest_limit" value="#{@conf.latest_limit}" size="2"> �ѥ�</p>
	<h3 class="subtitle">���鱡�h</h3>
	#{"<p>�O�_�n�q�X \"���鱡�h\" (�P��P�骺�L�h��x)�H</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{if @conf.show_nyear then " selected" end}>�q�I</option>
        <option value="false"#{if not @conf.show_nyear then " selected" end}>����</option>
	</select></p>
	HTML
end

# themes
@theme_location_comment = "<p>�z�i�H�b <a href=\"http://www.tdiary.org/20021001.html\">Theme Gallery</a>(�饻�y) ���o��h���G���D�D�I</p>"

add_conf_proc( 'theme', '�G���D�D' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">�G���D�D</h3>
	#{"<p>��ܱz��x�Q�n���G���D�D�μ˦���(CSS)�A�p�G�z��ܤF \"CSS specify\"�A�Цb�k(�U)�����̿�J CSS �Ҧb�����}�C </p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme">
		<option value="">CSS Specify-&gt;</option>
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

# comments
add_conf_proc( 'comment', '�j�T' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">�O�_�n�q�X�j�T�H</h3>
	#{"<p>�n���n�q�XŪ�̵̭��z���j�T�H </p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{if @conf.show_comment then " selected" end}>�n</option>
		<option value="false"#{if not @conf.show_comment then " selected" end}>���n</option>
	</select></p>
	<h3 class="subtitle">�n�q�X�X�g�j�T�H</h3>
	#{"<p>�b�u�̷s��x�v�Ρu�Y���x�v�ҥܤU�A�z�Q�n�q�X�h�ֽg�i�����j�T�H �۹�ӻ��A�b�u��g�v�ҥܤU�A�Ҧ����j�T���|�q�X�ӡC </p>" unless @conf.mobile_agent?}
	<p>�q�X <input name="comment_limit" value="#{ @conf.comment_limit }" size="3"> �g�j�T</p>
	HTML
end

# referer
add_conf_proc( 'referer', "�����嵲" ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">�O�_�q�X�嵲</h3>
	#{"<p>�z�i�H��ܬO�_�n�q�X�u�����嵲�v�C </p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{if @conf.show_referer then " selected" end}>�n</option>
		<option value="false"#{if not @conf.show_referer then " selected" end}>���n</option>
	</select></p>
	<h3 class="subtitle">�n�q�X�h���嵲</h3>
	#{"<p>�b�u�̷s��x�v�Ρu�Y���x�v�ҥܤU�A�z�Q�n�q�X�h�֭ӥi�����嵲�H �۹�ӻ��A�b�u��g�v�ҥܤU�A�Ҧ����嵲�j�T���|�q�X�ӡC </p>" unless @conf.mobile_agent?}
	<p>�q�X <input name="referer_limit" value="#{@conf.referer_limit}" size="3"> ���嵲</p>
	<h3 class="subtitle">�嵲���O�s�Ҧ�</h3>
	#{"<p>��ܦb��g�ҥܤ����嵲�O�s�Ҧ��A�o�ӿﶵ���γB�b���֡u�L�Ϊ��ѷӡv�C </p>" unless @conf.mobile_agent?}
	<p><select name="referer_day_only">
		<option value="true"#{if @conf.referer_day_only then " selected" end}>�u�N��g�ҥܤ����嵲�s�_��</option>
		<option value="false"#{if not @conf.referer_day_only then " selected" end}>�N�Ҧ��i�����嵲���s�_��</option>
	</select></p>
	<h3 class="subtitle">�u���C�J�嵲�v�C��</h3>
	#{"<p>�b�u�����嵲�v�̤��n�O���_�Ӫ��嵲�C�ХH regular expression �Φ��@��@����w�C�Ӥ��Q�O�������}�C </p>" unless @conf.mobile_agent?}
	<p>�Ь�<a href="#{@conf.update}?referer=no" target="referer">�w�]�]�w</a>�C</p>
	<p><textarea name="no_referer" cols="70" rows="10">#{@conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">���}���r���ഫ�W�h</h3>
	#{"<p>�N�u�����嵲�v���S�w�����}�ഫ����N�q���r���A�ХH regular expression �Φ��@��@����w�C�ӭn���r���ഫ�����}�C <p>" unless @conf.mobile_agent?}
	<p>�Ь�<a href="#{@conf.update}?referer=table" target="referer">�w�]�]�w</a>.</p>
	<p><textarea name="referer_table" cols="70" rows="10">#{@conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

# comment mail
def comment_mail_mime( str )
	[str.dup]
end

def comment_mail_conf_label; '�H�H��q���z���j�T'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']

	<<-HTML
	<h3 class="subtitle">�O�_�Q�ΫH��q�����j�T�H</h3>
	#{"<p>�п�ܦb���s���j�T�ɭn���n�H�q�l�l��q���z�C�аO�o�o���\\��ݭn�z�b tdiary.conf �]�w SMTP ���A���C</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{if @conf['comment_mail.enable'] then " selected" end}>�Хζl��q��</option>
        <option value="false"#{if not @conf['comment_mail.enable'] then " selected" end}>���ΤF</option>
	</select></p>
	<h3 class="subtitle">�����}</h3>
	#{"<p>�Ы��w�n����j�T�q�����q�l�l���}�A�@��g�@�Ӧ�}�C�p�G�o�̨S���t�~���w�A�h�q���H�N�|�H��z���q�l�l���}�C</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{CGI::escapeHTML( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">�H����D</h3>
	#{"<p>���w�@�ӷ|�\�b�q���H���u�H����D�v�}�Y�B���r��C�H����D�|�O \"�z���w���r��:DATE-SERIAL NAME\" ���˦��C \"date\" �O�z��x�o������A���O�p�G�z�t����w�F������˦��A���D�h�|�ܬ� \"�z���w���r��-SERIAL NAME\" (ex: \"hoge:%Y-%m-%d\")</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{CGI::escapeHTML( @conf['comment_mail.header'])}"></p>
	HTML
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/en/?#{@conf.style}Style">���g����</a>|
end

add_conf_proc( 'csrf_protection', 'CSRF Protection' ) do
	err = saveconf_csrf_protection
	errstr = ''
	case err
	when :param
		errstr = '<p class="message">Invalid options specified. Configuration not saved.</p>'
	when :key
		errstr = '<p class="message">No key specified. Configuration not saved.</p>'
	end
	csrf_protection_method = @conf.options['csrf_protection_method'] || 1
	csrf_protection_key = @conf.options['csrf_protection_key'] || ''
	<<-HTML
	#{errstr}
	<p>This page configures a protection scheme to prevent "cross-site request forgery" (CSRF) attacks.</p>
	<p>To make CSRF attack, a malicious person prepares a trap link in some web page and lets you visit that page.
	When the trap link is invoked (either by Javascript or your mouse click), <i>your</i> web browser sends a forged request to tDiary.
	Thus, neither encryption nor usual password protection can serve as a protection mechanism.
	TDiary provies two methods -- "checking referer" and "checking CSRF key" -- to prevent such attacks.</p>
	<div class="section">
	<h3 class="subtitle">Checking Referer</h3>
	<h4 class="subtitle">Checks for Referer values</h4>
	<p>#{if [0,1,2,3].include?(csrf_protection_method) then
            '<input type="checkbox" name="check_enabled2" value="true" checked disabled>
            <input type="hidden" name="check_enabled" value="true">'
          else
            '<input type="checkbox" name="check_enabled" value="true">'
        end}Enabled (default)</input>
	</p>
	#{"<p>Configures Referer-based CSRF protection.
	TDiary checks the Referer value sent from your web browser. If the post request comes from some outer page,
	the request will be rejected. This setting can't be disabled through web-based configuration, for safety reasons.</p>
	" unless @conf.mobile_agent?}
	<h3 class="subtitle">Handling of Referer-disabled browsers</h3>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>Reject (default)</input>
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>Accept</input>
	</p>
	#{"<p>Configures handling for requests without any Referer: value.
	By default tDiary rejects such request for safety reasons.
	If your browser is configured not to send Referer values, alter that setting to allow sending Referer, at least for
	originating sites. If it is impossible, configure the key-based CSRF protection below, and 
	change this setting to \"Accept\".</p>
	" unless @conf.mobile_agent?}
	</div>
	<div class="section">
	<h3 class="subtitle">Checking CSRF key</h3>
	<h4>Checks for CSRF protection key</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>Enabled</input>
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>Disabled (default)</input>
	</p>
	#{"<p>TDiary can add a secret key for every post form to prevent CSRF. As long as attackers do not know the secret key,
	forged requests will not be granted. To enable this feature, you must specify the secret key below.
	To allow Referer-disabled browsers, you must enable this setting.</p>" unless @conf.mobile_agent?}
	<h4>CSRF protection key</h4>
	<p><input type="text" name="key" value="#{CGI::escapeHTML csrf_protection_key}" size="20"></p>
	#{"<p>A secret key used for key-based CSRF protection. Specify a secret string which is not easy to guess.
	If this key is leaked, CSRF attacks can be exploited.
	Do not use any passwords used in other places. You need not to remember this phrase to type in.</p>" unless @conf.mobile_agent?}
	#{"<p class=\"message\">Caution: 
	Your browser seems not to be sending any Referers, although Referer-based protection is enabled.
	<a href=\"#{@conf.update}?conf=csrf_protection\">Please open this page again via this link</a>.
	If you see this message again, you must either change your browser setting (temporarily to change these settings, at least),
	or edit \"tdiary.conf\" directly.</p>" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	</div>
	HTML
end
