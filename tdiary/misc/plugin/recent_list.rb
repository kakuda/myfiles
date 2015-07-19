# $Revision: 1.19 $
# recent_list: �Ƕ�񤤤������Υ����ȥ롤���֥����ȥ��ɽ������
#   �ѥ�᥿(���å����̤���������):
#     days:            ����ʬ��������ɽ�����뤫(20)
#     date_format:     ����ɽ���ե����ޥå�(���������եե����ޥå�)
#     title_with_body: true�ǳƥѥ饰��դؤΥ�󥯤�title°���ˤ��Υѥ饰��դΰ��������(false)
#     show_size:       true������Ĺ��ɽ��(false)
#     show_title:      true�ǳ����Υ����ȥ��ɽ��(false)
#
#   ���: �����奢�⡼�ɤǤϻȤ��ޤ���
#   ����: �����ȥ�ꥹ�Ȥ�������������ϡ��쥤�����Ȥ��פ��ʤ����
#         �ʤ�ޤ��󡣥إå���եå���table������Ȥä��ꡢCSS��񤭴�
#         ����ɬ�פ�����Ǥ��礦��
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
=begin ChengeLog
2003-09-25 TADA Tadashi <sho@spc.gr.jp>
	* use @conf.shorten.

2003-03-06 Junichiro Kita <kita@kitaj.no-ip.com>
	* section.shorten -> section.body.shorten. thanks to mput <root@mput.dip.jp>.

2003-02-11 Junichiro Kita <kita@kitaj.no-ip.com>
	* support for category. thanks to garsl<garsl@imasy.org> and yoshimi.

2002-12-20 TADA Tadashi <sho@spc.gr.jp>
	* use Plugin#apply_plugin.

2002-10-06 TADA Tadashi <sho@spc.gr.jp>
	* for tDiary 1.5.0.20021003.
=end

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class TDiaryMonth
		attr_reader :diaries
	end
end
MODIFY_CLASS

def recent_list(days = 30, date_format = nil, title_with_body = nil, show_size = nil, show_title = nil, extra_erb = 'obsolete')
	days = days.to_i
	date_format ||= @date_format

	result = ""
	if extra_erb != 'obsolete'
		result << %Q|<p class="message">option 'extra_erb' is obsolete!<p>|
	end

	cgi = CGI::new
	def cgi.referer; nil; end

	catch(:exit) {
		@years.keys.sort.reverse_each do |year|
			@years[year].sort.reverse_each do |month|
				cgi.params['date'] = ["#{year}#{month}"]
				m = TDiaryMonth::new(cgi, '', @conf)
				m.diaries.keys.sort.reverse_each do |date|
					next unless m.diaries[date].visible?
					result << %Q|<p class="recentitem"><a href="#{@index}#{anchor date}">#{m.diaries[date].date.strftime(date_format)}</a>\n|
					if show_title and m.diaries[date].title
						result << %Q| #{m.diaries[date].title}|
					end
					if show_size == true
						s = 0
						m.diaries[date].each_section do |section|
							s = s + section.to_s.size.to_i
						end
						result << ":#{s}"
					end
					result << %Q|</p>\n<div class="recentsubtitles">\n|
					i = 1
					if !@plugin_files.grep(/\/category.rb$/).empty? and m.diaries[date].categorizable?
						m.diaries[date].each_section do |section|
							if section.stripped_subtitle
								result << %Q| <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}"|
								result << %Q| title="#{CGI::escapeHTML( @conf.shorten( apply_plugin( section.body_to_html, true) ) )}"| \
									if title_with_body == true
								result << %Q|>#{i}</a>. | \
										<< %Q|#{section.stripped_subtitle_to_html}<br>\n|
							end
							i += 1
						end
					else
						m.diaries[date].each_section do |section|
							if section.subtitle
								result << %Q| <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}"|
								result << %Q| title="#{CGI::escapeHTML( @conf.shorten( apply_plugin(section.body_to_html, true) ) )}"| \
									if title_with_body == true
								result << %Q|>#{i}</a>. | \
										<< %Q|#{section.subtitle_to_html}<br>\n|
							end
							i += 1
						end
					end
					result << "</div>\n"
					days -= 1
					throw :exit if days == 0
				end
			end
		end
	}
	apply_plugin( result )
end
# vim: ts=3
