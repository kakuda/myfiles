# gradient.rb $Revision: 1.1 $
#
# gradient.rb: ʸ�����礭�����Ѳ������ʤ���ɽ��
#   �ѥ�᥿:
#     str:        ʸ����
#     first_size: ����ʸ��������(���͡�ñ��pt)
#     last_size:  ����ʸ��������(���͡�ñ��pt)
#
#   ��: �֤���ʤ��Ȥ�Ǥ��ޤ��פ�10pt����30pt�˳���
#     <%=gradient '����ʤ��Ȥ�Ǥ��ޤ�', 10, 30 %>
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20020122#p02
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
#
def gradient( str, first_size, last_size )
	ary = str.split( // )
	len = ary.length - 1
	result = ""
	fontsize = first_size.to_f
	sd = ( last_size - first_size ).to_f / len
	ary.each do |x|
		s = sprintf( '%d',fontsize.round )
		result << %Q[<span style="font-size: #{s}pt;">#{x}</span>]
		fontsize += sd
	end
	result
end

