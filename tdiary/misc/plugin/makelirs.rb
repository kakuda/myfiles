# makelirs.rb $Revision: 1.13 $
#
# 更新情報をLIRSフォーマットのファイルに吐き出す
#
#   pluginディレクトリに置くだけで動作します。
#
#   tdiary.confにおいて、@options['makelirs.file']に
#   ファイル名を指定すると、そのファイルを出力先の
#   LIRSファイルとします。無指定時にはindex.rbと同じ
#   パスにantenna.lirsというファイルになります。
#   いずれも、Webサーバから書き込める権限が必要です。
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

