# makelirs.rb $Revision: 1.13 $
#
# ���������LIRS�ե����ޥåȤΥե�������Ǥ��Ф�
#
#   plugin�ǥ��쥯�ȥ���֤�������ư��ޤ���
#
#   tdiary.conf�ˤ����ơ�@options['makelirs.file']��
#   �ե�����̾����ꤹ��ȡ����Υե������������
#   LIRS�ե�����Ȥ��ޤ���̵������ˤ�index.rb��Ʊ��
#   �ѥ���antenna.lirs�Ȥ����ե�����ˤʤ�ޤ���
#   ������⡢Web�����Ф���񤭹���븢�¤�ɬ�פǤ���
#
# Copyright (C) 2002 by Kazuhiro NISHIYAMA
#

add_header_proc do
	<<-LINK
	<!--link rel="alternate" type="application/x-lirs" title="lirs" href="#{File::basename( @options['makelirs.file'] || 'antenna.lirs' )}"-->
	LINK
end


add_update_proc do
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		unless Time.method_defined?(:utc_offset)
			class Time
				def utc_offset
					l = self.dup.localtime
					u = self.dup.utc
	
					if l.year != u.year
						off = l.year < u.year ? -1 : 1
					elsif l.mon != u.mon
						off = l.mon < u.mon ? -1 : 1
					elsif l.mday != u.mday
						off = l.mday < u.mday ? -1 : 1
					else    
						off = 0
					end
	
					off = off * 24 + l.hour - u.hour
					off = off * 60 + l.min - u.min
					off = off * 60 + l.sec - u.sec
	
					return off
				end
			end
		end
	MODIFY_CLASS

	file = @options['makelirs.file'] || 'antenna.lirs'

	# create_lirs
	t = TDiaryLatest::new( @cgi, "latest.rhtml", @conf )
	body = t.eval_rhtml
	# escape comma
	e = proc{|str| str.gsub(/[,\\]/) { "\\#{$&}" } }

	now = Time.now
	utc_offset = now.utc_offset

	lirs = "LIRS,#{t.last_modified.tv_sec},#{Time.now.tv_sec},#{utc_offset},#{body.size},#{e[@conf.base_url]},#{e[@html_title]},#{e[@author_name]},,\n"
	File::open( file, 'w' ) do |o|
		o.puts lirs
	end
	begin
		File::utime( t.last_modified.tv_sec, t.last_modified.tv_sec, file )
	rescue
	end
end

