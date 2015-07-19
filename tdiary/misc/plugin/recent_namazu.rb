# recent_namazu.rb $Revision 1.0 $
#
# recent_namazu: Namazu�����쿷������
# 		 namazi.cgi���������븡��������ɥ�(NMZ.slog)����
#		 �ǿ�xx��ʬ�θ������ɽ�����ޤ���
# �ѥ�᥿:
#   file:       ����������ɥ��ե�����̾(���Хѥ�ɽ��) 
#   namazu:     �ʤޤ�cgi̾ 
#   limit:      ɽ�����(̤�����:5) 
#   sep:        ���ѥ졼��(̤�����:����)
#   make_link:  <a>���������뤫?(̤�����:��������)    
#
#
# Copyright (c) 2002 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
# Distributed under the GPL

def recent_namazu(file, namazu, limit = 5, sep='&nbsp;', make_link = true)
	begin
		lines = []
		log = open(file)
		if log.stat.size > 300 * limit then
			log.seek(-300 * limit,IO::SEEK_END)
		end
		log.each_line do |line|
			lines << line
		end

		result = []
		lines.reverse.each_with_index do |line,idx|
			break if idx >= limit
			word = line.split(/\t/)[0]
			if make_link
				result << %Q[<a href="#{namazu}?query=#{CGI::escapeHTML(word)}">#{CGI::escapeHTML(word)}</a>]
			else
				result << CGI::escapeHTML(word)
			end
		end
		result.join( sep )
	rescue
		%Q[<p class="message">#$! (#{$!.class})<br>cannot read #{file}.</p>]
	end
end
