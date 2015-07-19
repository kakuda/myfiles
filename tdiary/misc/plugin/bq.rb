# bq.rb $Revision: 1.2 $
#
# bq: blockquote��Ȥä����Ѥ���������
#   �ѥ�᥿:
#     src:   ���Ѥ���ƥ�����
#     title: ���Ѹ��Υ����ȥ�
#     url:   ���Ѹ���URL
#
#   ���Ѹ������ȥ�򤦤ޤ�ɽ������ˤϡ��������륷���Ȥ�p.source��
#   �������ɬ�פ�����ޤ��������������:
#
#       p.source {
#          margin-top: 0.3em;
#          text-align: right;
#          font-size: 90%;
#       }
#
# Copyright (C) 2002 by s.sawada <http://mwave.sppd.ne.jp/diary/>
#
=begin ChangeLog
2002-04-15 TADA Tadashi <http://sho.tdiary.net/>
	* omit title or url.
	* sarround with <p>...</p> by each lines in src.

2002-04-15 s.sawada
	* create.
=end

def bq( src, title = nil, url = nil )
	if url then
		result = %Q[<blockquote cite="#{url}" title="#{title}">\n]
	elsif title
		result = %Q[<blockquote title="#{title}">\n]
	else
		result = %Q[<blockquote>\n]
	end
	result << %Q[<p>#{src.gsub( /\n/, "</p>\n<p>" )}</p>\n].sub( %r[<p></p>], '' )
	result << %Q[</blockquote>\n]
	if url then
		result << %Q[<p class="source">[<cite><a href="#{url}" title="#{title}������">#{title}</a></cite>������]</p>\n]
	elsif title
		result << %Q[<p class="source">[<cite>#{title}</cite>������]</p>\n]
	end
	result
end

