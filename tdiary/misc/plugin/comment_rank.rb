# comment_rank.rb $Revision: 1.3 $
#
# comment_rank: ツッコミの数でランキング
#   パラメタ:
#     max:  最大表示数(未指定時:5)
#     sep:  セパレータ(未指定時:空白)
#     except:        無視する名前(いくつもある場合は,で区切って並べる)
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20011221#p02
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
#
def comment_rank( max = 5, sep = '&nbsp;', *except )
	name = Hash::new(0)
	@diaries.each_value do |diary|
		diary.each_comment( 100 ) do |comment|
			next if except.include?(comment.name)
			name[comment.name] += 1
		end
	end
	result = []
	name.sort{|a,b| (a[1])<=>(b[1])}.reverse.each_with_index do |ary,idx|
		break if idx >= max
		result << "<strong>#{idx+1}.</strong>#{CGI::escapeHTML( ary[0].to_s )}(#{ary[1].to_s})"
	end
	result.join( sep )
end

