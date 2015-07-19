# ja/category.rb $Revision: 1.7 $
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

def category_title
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode
	case mode
	when :year
		period = "#{info.year}"
	when :half
		period = (info.month.to_i == 1 ? "1st half" : "2nd half")
		period = "#{info.year} #{period}" if info.year
	when :quarter
		period = info.month
		period = "#{info.year}/#{period}" if info.year
	when :month
		period = info.month.to_i
		period = "#{info.year}/#{period}" if info.year
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
	@conf['category.this_year'] ||= 'this year'
	@conf['category.this_half'] ||= 'this half'
	@conf['category.this_quarter'] ||= 'this quarter'
	@conf['category.this_month'] ||= 'this month'
	@conf['category.all_diary'] ||= 'all diary'
	@conf['category.all_category'] ||= 'all category'
	@conf['category.all'] ||= 'all diary/all category'
end
category_init_local

@category_conf_label = 'Category'
def category_conf_html
	r = <<HTML
<h3 class="subtitle">Create category index</h3>
<p>
To use the category feature, you should create category index.
Press 
<a href="#{@conf.update}?conf=category;category_initialize=1">here</a>
to create category index.
It takes several or several tens of second to create it.
</p>

<h3 class="subtitle">Edit Support</h3>
<p>
Category names can be shown under the 'Article' form.
</p>
<p>
<select name="category.edit_support">
<option value="true"#{" selected" if @conf['category.edit_support']}>Show</option>
<option value="false"#{" selected" unless @conf['category.edit_support']}>Hide</option>
</select>
</p>

<h3 class="subtitle">Header</h3>
<p>
This text is inserted into top of category view.
"&lt;%= category_navi %&gt;" genaretes navigation buttons for category, 
and "&lt;%= category_list %&gt;" lists all category names.
You can use plugins and write any HTML tags.
</p>

<p>Header 1: inserted under the navigtion buttons.</p>
<textarea name="category.header1" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header1'])}</textarea>

<p>Header 2: inserted under the &lt;H1&gt;.</p>
<p><textarea name="category.header2" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header2'])}</textarea></p>

<h3 class="subtitle">Default period</h3>
<p>
Specify the default display period for category view.
</p>
<p><select name="category.period">
HTML
	[
		['month', 'month', false],
		['quarter', 'quarter', true],
		['half-year', 'half', false],
		['year', 'year', false],
		['all', 'all', false],
	].each do |text, value, default|
		selected = @conf["category.period"] ? @conf["category.period"] == value : default
		r << <<HTML
<option value="#{value}"#{" selected" if selected}>#{text}</option>
HTML
	end
	r << <<HTML
</select></p>

<h3 class="subtitle">Button labels</h3>
<p>
Specify button labels.
$1 and $2 in labels are replaced with year and month.
</p>
<table border="0">
<tr><th>button name</th><th>label</th><th>sample</th></tr>
HTML
	[
		['previous year', 'category.prev_year'],
		['next year', 'category.next_year'],
		['previous half', 'category.prev_half'],
		['next half', 'category.next_half'],
		['previous quarter', 'category.prev_quarter'],
		['next quarter', 'category.next_quarter'],
		['previous month', 'category.prev_month'],
		['next month', 'category.next_month'],
		['this year', 'category.this_year'],
		['this half', 'category.this_half'],
		['this quarter', 'category.this_quarter'],
		['this month', 'category.this_month'],
		['all diary', 'category.all_diary'],
		['all category', 'category.all_category'],
		['all diary/all category', 'category.all'],
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

@category_icon_none_label = 'no icon'
@category_icon_conf_label = 'Category Icons'
def category_icon_conf_html
	r = ''
	unless @conf.secure
		r << <<HTML
<h3 class="subtitle">Location of category icons</h3>
<p>
Specify the directory and url of category icons.
</p>
<p>
<dl>
<dt>Directory:</dt>
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
	<<HTML
<h3 class="subtitle">Category Icons</h3>
<p>
<table>
	<tr><th>Category</th><th>Icon</th></tr>
#{str}
</table>
</p>
<hr>
<h3 class="subtitle">Sample icons</h3>
<p>
You can take your choice from these icons.
Move mouse pointer on an icon, the icon's name will pop up.
</p>
<p>
#{category_icon_sample}
</p>
HTML
end
# vim: ts=3
