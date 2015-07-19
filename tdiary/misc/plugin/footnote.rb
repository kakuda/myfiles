# footnote.rb $Revision: 1.8 $
#
# fn: ����plugin
#   �ѥ�᥿:
#     text: ������ʸ
#     mark: ����ޡ���('*')
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
=begin ChangeLog
2002-05-06 MUTOH Masao <mutoh@highway.ne.jp>
	* change file encoding from ISO-2022-JP to EUC-JP.

2002-03-12 TADA Tadashi <sho@spc.gr.jp>
	* runable in secure mode.
=end

# initialize instance variable as taint
@footnote_name = ""
@footnote_name.taint
@footnote_url = ""
@footnote_url.taint
@footnote_mark_name = ""
@footnote_mark_name.taint
@footnote_mark_url = ""
@footnote_mark_url.taint
@footnotes = []
@footnotes.taint
@footnote_index = [0]
@footnote_index.taint

def fn(text, mark = '*')
	if @footnote_name and /^append|replace$/ !~ @mode then
		@footnote_index[0] += 1
		@footnotes << [@footnote_index[0], text, mark]
		r = %Q|<span class="footnote"><a |
		r << %Q|name="#{@footnote_mark_name % @footnote_index[0]}" | if @mode == 'day'
		r << %Q|href="#{@footnote_url % @footnote_index[0]}" title="#{CGI::escapeHTML text}">#{mark}#{@footnote_index[0]}</a></span>|
	else
 		""
	end
end

add_body_enter_proc(Proc.new do |date|
	date = date.strftime("%Y%m%d")
	@footnote_name.replace "f%02d"
	@footnote_url.replace "#{@index}#{anchor date}##{@footnote_name}"
	@footnote_mark_name.replace "fm%02d"
	@footnote_mark_url.replace "#{@index}#{anchor date}##{@footnote_mark_name}"
	@footnotes.clear
	@footnote_index[0] = 0
	""
end)

add_body_leave_proc(Proc.new do |date|
	if @footnote_name and @footnotes.size > 0
		%Q|<div class="footnote">\n| +
		@footnotes.collect do |fn|
			r = %Q|  <p class="footnote"><a |
			r << %Q|name="#{@footnote_name % fn[0]}" | if @mode == 'day'
			r << %Q|href="#{@footnote_mark_url % fn[0]}">#{fn[2]}#{fn[0]}</a>&nbsp;#{fn[1]}</p>|
		end.join("\n") +
		%Q|\n</div>\n|
	else
		""
	end
end)
# vim: ts=3
