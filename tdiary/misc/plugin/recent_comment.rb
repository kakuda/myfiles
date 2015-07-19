# recent_comment.rb $Revision: 1.4 $
#
# recent_comment: �Ƕ�Υĥå��ߤ�ꥹ�ȥ��åפ���
#   �ѥ�᥿:
#     max:    ����ɽ����(̤�����:3)
#     sep:    ���ѥ졼��(̤�����:����)
#     form:   ���դΥե����ޥå�(̤�����:(����������ɽ�� ��:ʬ))
#     except: ̵�뤹��̾��(̤�����:nil)
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20011225#p07
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
# Modified: by kitaj <http://kitaj.no-ip.com/>
#
def recent_comment( max = 3, sep = '&nbsp;', form = nil, except = nil )
	form = "(#{@date_format + ' %H:%M'})" unless form
	comments = []
	date = {}
	index = {}
	@diaries.each_value do |diary|
		next unless diary.visible?
		diary.each_comment_tail( max ) do |comment, idx|
			if except && (/#{except}/ =~ comment.name)
				next
			end
			comments << comment
			date[comment.date] = diary.date
			index[comment.date] = idx
		end
	end
	result = []
	comments.sort{|a,b| (a.date)<=>(b.date)}.reverse.each_with_index do |com,idx|
		break if idx >= max
		str = ''
		str << %Q[<strong>#{idx+1}.</strong>]
	  	str << %Q[<a href="#{@index}#{anchor date[com.date].strftime( '%Y%m%d' )}#c#{'%02d' % index[com.date]}"]
		str << %Q[ title="#{CGI::escapeHTML( com.shorten( @conf.comment_length ) )}">]
		str << %Q[#{CGI::escapeHTML( com.name )}]
		str << %Q[#{com.date.dup.strftime( form )}</a>]
		result << str
	end
	result.join( sep )
end

