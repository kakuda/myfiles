# titile_list.rb $Revision: 1.15 $
#
# title_list: ����ɽ�����Ƥ����Υ����ȥ�ꥹ�Ȥ�ɽ��
#   �ѥ�᥿(���å����̤���������):
#     rev:       �ս�ɽ��(false)
#
# ����: �����ȥ�ꥹ�Ȥ�������������ϡ��쥤�����Ȥ��פ��ʤ����
# �ʤ�ޤ��󡣥إå���եå���table������Ȥä��ꡢCSS��񤭴�����ɬ
# �פ�����Ǥ��礦��
#
def title_list( rev = false, extra_erb = 'obsolete' )
	result = ''
	if extra_erb != 'obsolete'
		result << %Q|<p class="message">option 'extra_erb' is obsolete!<p>|
	end
	keys = @diaries.keys.sort
	keys = keys.reverse if rev
	keys.each do |date|
		next unless @diaries[date].visible?
		result << %Q[<p class="recentitem"><a href="#{@index}#{anchor date}">#{@diaries[date].date.strftime( @date_format )}</a></p>\n<div class="recentsubtitles">\n]
		if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
			@diaries[date].each_section do |section|
				result << %Q[#{section.stripped_subtitle_to_html}<br>\n] if section.stripped_subtitle
			end
		else
			@diaries[date].each_section do |section|
				result << %Q[#{section.subtitle_to_html}<br>\n] if section.subtitle
			end
		end
		result << "</div>\n"
	end
	apply_plugin( result )
end

