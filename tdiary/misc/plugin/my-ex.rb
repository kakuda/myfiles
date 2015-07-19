# my-ex.rb $Revision: 1.12 $
#
# my(��ĥ��): my�ץ饰������ĥ����title°���˻���������Ƥ��������ޤ���
#             �����褬���������ξ���(�����)���֥����ȥ��
#             �ĥå��ߤξ��ϥĥå�����ͤ�̾�������Ƥΰ�����Ȥ��ޤ���
# �ѥ�᥿:
#   a:   ��ʬ��������Υ�������('YYYYMMDD#pNN' �ޤ��� 'YYYYMMDD#cNN')
#   str: ��󥯤ˤ���ʸ����
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL

unless @conf.mobile_agent?

def my( a, str, title = nil )
	date, noise, frag = a.scan( /^(\d{4}|\d{6}|\d{8})([^\d]*)?#?([pct]\d\d)?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	place, frag = frag.scan( /([cpt])(\d\d)/ )[0] if frag
	if date and frag and @diaries[date] then
		case place
		when 'p'
			section = nil
			idx = 1
			@diaries[date].each_section do |s|
				section = s
				break if idx == frag.to_i 
				idx += 1
			end
			if section and section.subtitle then
				title = CGI::escapeHTML( "#{apply_plugin(section.subtitle_to_html, true)}" )
			end
		when 'c'
			com = nil
			@diaries[date].each_comment( frag.to_i ) {|c| com = c}
			if com then
				title = CGI::escapeHTML( "[#{com.name}] #{com.shorten( @conf.comment_length )}" )
			end
		when 't'
			if @plugin_files.grep(/tb-show.rb\z/)
				tb = nil
				@diaries[date].each_visible_trackback( frag.to_i ) {|t, idx| tb = t}
				if tb then
					url, name, tbtitle, excerpt = tb.body.split( /\n/,4 )
					title = CGI::escapeHTML( "[#{name}] #{@conf.shorten( excerpt, @conf.comment_length )}" )
				end
			end
		end
	end
	if title then
		%Q[<a href="#{@index}#{anchor anc}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{@index}#{anchor anc}">#{str}</a>]
	end
end

end
