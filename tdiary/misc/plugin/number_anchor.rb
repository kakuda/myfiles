# number_anchor.rb $Revision: 1.3 $
#
# number_anchor: ���󥫡���id°�����ղä���
#          ���󥫡�������ۤʤ��Τˤ��뤿��Τ��
# 	   ���Ѥ��뤵���ϡ�������̤Υإå���
#	   <%= use_number_anchor( ���󥫡��μ�� ) %>
#	   �Ƚ񤤤Ƥ���������
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
# Distributed under the GPL
#

def use_number_anchor ( n = 1 )
	@use_number_anchor = true
	@total_anchor = n
	""
end

alias :_orig_anchor :anchor

def anchor( s )
	if @use_number_anchor == true then
	if /^(\d+)#?([pct])?(\d*)?$/ =~ s then
		if $2 then
			n = $3.to_i
			if n && n > @total_anchor then
				n = (n % @total_anchor)
			end
			"#{_orig_anchor(s)}\" class=\"#$2#{'%02d' % n}"
		else
			_orig_anchor(s)
		end
	else
		""
	end
	else
		_orig_anchor(s)
	end
end
