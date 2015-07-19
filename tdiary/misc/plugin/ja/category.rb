# ja/category.rb $Revision: 1.8 $
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

def category_title
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode
	case mode
	when :year
		period = "#{info.year}ǯ"
	when :half
		period = (info.month.to_i == 1 ? "��Ⱦ��" : "��Ⱦ��")
		period = "#{info.year}ǯ #{period}" if info.year
	when :quarter
		period = "��#{info.month.to_i}��Ⱦ��"
		period = "#{info.year}ǯ #{period}" if info.year
	when :month
		period = "#{info.month.to_i}��"
		period = "#{info.year}ǯ #{period}" if info.year
	end
	period = " (#{period})" if period

	"[#{CGI.escapeHTML(info.category.join('|'))}#{period}]"
end

def category_init_local
	@conf['category.prev_year'] ||= '&laquo;($1)'
	@conf['category.next_year'] ||= '($1)&raquo;'
	@conf['category.prev_half'] ||= '&laquo;($1-$2)'
	@conf['category.next_half'] ||= '($1-$2)&raquo;'
	@conf['category.prev_quarter'] ||= '&laquo;($1-$2)'
	@conf['category.next_quarter'] ||= '($1-$2)&raquo;'
	@conf['category.prev_month'] ||= '&laquo;($1-$2)'
	@conf['category.next_month'] ||= '($1-$2)&raquo;'
	@conf['category.this_year'] ||= 'ǯ'
	@conf['category.this_half'] ||= 'Ⱦ��'
	@conf['category.this_quarter'] ||= '��Ⱦ��'
	@conf['category.this_month'] ||= '��'
	@conf['category.all_diary'] ||= '������'
	@conf['category.all_category'] ||= '�����ƥ���'
	@conf['category.all'] ||= '������/�����ƥ���'
end
category_init_local

@category_conf_label = '���ƥ���'
def category_conf_html
	r = <<HTML
<h3 class="subtitle">���ƥ��ꥤ��ǥå����κ���</h3>
<p>
���ƥ����ε�ǽ�����Ѥ���ˤϥ��ƥ��ꥤ��ǥå����򤢤餫����������Ƥ���ɬ�פ�����ޤ���
���ƥ��ꥤ��ǥå������������ˤ�
<a href="#{@conf.update}?conf=category;category_initialize=1">����</a>
�򥯥�å����Ƥ���������
�������̤䥵���Ф���ǽ�ˤ���ޤ��������ä�������äǥ���ǥå����κ����Ͻ�λ���ޤ���
</p>

<h3 class="subtitle">�����Խ����ݡ���</h3>
<p>
�����Խ����̤Ρ���ʸ�פβ��˥��ƥ���̾�����ɽ�����뤳�Ȥ��Ǥ��ޤ���
���ƥ���̾�򥯥�å�����ȡ���ʸ�פˤ��Υ��ƥ���̾����������ޤ�(��JavaScript)��
</p>
<p>
<select name="category.edit_support">
<option value="true"#{" selected" if @conf['category.edit_support']}>ɽ������</option>
<option value="false"#{" selected" unless @conf['category.edit_support']}>ɽ�����ʤ�</option>
</select>
</p>

<h3 class="subtitle">�إå�</h3>
<p>
���̾�����ɽ������ʸ�Ϥ���ꤷ�ޤ���
��&lt;%= category_navi %&gt;�פǡ����ƥ�����ò������ʥӥ��������ܥ����ɽ�����뤳�Ȥ��Ǥ��ޤ���
�ޤ���&lt;%= category_list%&gt;�פǥ��ƥ���̾������ɽ�����뤳�Ȥ��Ǥ��ޤ���
����¾���Ƽ�ץ饰�����HTML�򵭽ҤǤ��ޤ���
</p>

<p>�إå�1���ʥӥ��������ܥ���Τ�������ɽ������ޤ���</p>
<textarea name="category.header1" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header1'])}</textarea>

<p>�إå�2��H1�Τ�������ɽ������ޤ���</p>
<p><textarea name="category.header2" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header2'])}</textarea></p>

<h3 class="subtitle">�ǥե���Ȥ�ɽ������</h3>
<p>
���ƥ���ɽ���⡼�ɤΥǥե���Ȥ�ɽ�����֤���ꤷ�ޤ���
</p>
<p>
<select name="category.period">
HTML
	[
		['��', 'month', false],
		['��Ⱦ��', 'quarter', true],
		['Ⱦ��', 'half', false],
		['ǯ', 'year', false],
		['������', 'all', false],
	].each do |text, value, default|
		selected = @conf["category.period"] ? @conf["category.period"] == value : default
		r << <<HTML
<option value="#{value}"#{" selected" if selected}>#{text}</option>
HTML
	end
	r << <<HTML
</select>
</p>

<h3 class="subtitle">�ܥ����٥�</h3>
<p>
�ʥӥ��������ܥ���Υ�٥����ꤷ�ޤ���
��٥����$1��$2�ϡ����줾���ǯ�סַ�פ�ɽ�����ͤ��ִ�����ޤ���
</p>
<table border="0">
<tr><th>�ܥ���̾</th><th>��٥�</th><th>����ץ�</th></tr>
HTML
	[
		['��ǯ', 'category.prev_year'],
		['��ǯ', 'category.next_year'],
		['����Ⱦǯ', 'category.prev_half'],
		['����Ⱦǯ', 'category.next_half'],
		['����Ⱦ��', 'category.prev_quarter'],
		['����Ⱦ��', 'category.next_quarter'],
		['���', 'category.prev_month'],
		['���', 'category.next_month'],
		['��ǯ', 'category.this_year'],
		['��Ⱦ��', 'category.this_half'],
		['����Ⱦ��', 'category.this_quarter'],
		['����', 'category.this_month'],
		['������', 'category.all_diary'],
		['�����ƥ���', 'category.all_category'],
		['������/�����ƥ���', 'category.all'],
	].each do |button, name|
		r << <<HTML
<tr>
	<td>#{button}</td>
	<td><input type="text" name="#{name}" value="#{CGI.escapeHTML(@conf[name])}" size="30"></td>
	<td><p><span class="adminmenu"><a>#{@conf[name].sub(/\$1/, "2004").sub(/\$2/, "2")}</a></span></p></td>
</tr>
HTML
	end
	r << <<HTML
</table>
HTML
end

@category_icon_none_label = '��������ʤ�'
@category_icon_conf_label = '���ƥ��ꥢ������'
def category_icon_conf_html
	r = ''
	unless @conf.secure
		r << <<HTML
<h3 class="subtitle">���ƥ��ꥢ��������֤����</h3>
<p>
���ƥ��ꥢ�������Ѥβ�������¸����Ƥ���ǥ��쥯�ȥ�Ȥ���URL����ꤷ�ޤ���
</p>
<p>
<dl>
<dt>�ǥ��쥯�ȥ�:</dt>
<dd><input name="category.icon_dir" value="#{@category_icon_dir}" size="30"></dd>
<dt>URL:</dt>
<dd><input name="category.icon_url" value="#{@category_icon_url}" size="30"></dd>
</dl>
</p>
<hr>
HTML
	end

	str = ''
	@categories.each do |c|
		str << %Q|\t<tr>\n\t\t<td>#{c}</td>\n\t\t<td>\n|
		str << category_icon_select(c)
		str << %Q|<img src="#{@category_icon_url}#{@category_icon[c]}">| if @category_icon[c]
		str << %Q|</td>\n\t</tr>\n|
	end
	r << <<HTML
<h3 class="subtitle">���ƥ��ꥢ������</h3>
<p>
�ƥ��ƥ���Υ��������ɥ�åץ�����ꥹ�Ȥ������򤷤ޤ���
<p>
<table>
	<tr><th>���ƥ���</th><th>��������</th></tr>
#{str}
</table>
</p>
<hr>
<h3 class="subtitle">�������󥵥�ץ�</h3>
<p>
�����ǽ�ʥ�����������Ǥ���
��������˥ޥ�������������碌��ȥ�������Υե�����̾���ݥåץ��å�ɽ������ޤ���
</p>
<p>
#{category_icon_sample}
</p>
HTML
	r
end

# vim: ts=3
