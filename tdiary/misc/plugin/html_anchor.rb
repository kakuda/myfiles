# html_anchor $Revision: 1.4 $
#
# anchor: ���󥫡����YYYYMMDD.html�ס�YYYYMM.html�׷������֤�������
#         tDiary���鼫ưŪ�˸ƤӽФ����Τǡ��ץ饰����ե������
#         ���֤�������Ǥ褤�����Υץ饰�����ͭ���˻Ȥ�����ˤϡ�
#         Web������¦�������ѹ���ɬ�ס�Apache��Ȥ���硢�ʲ���2�Ĥ�
#         ��ˡ���Τ��Ƥ��롣
#
#         (1) mod_rewrite�ȹ�碌�����Ѥ���(�侩)
#             ����: http://sho.tdiary.net/20020301.html#p04
#
#         (2) ErrorDocument�����Ѥ���
#             .htaccess�˰ʲ���������ɲä���(your_URL_of_index.rb�Ϥ��ʤ�
#             ��������index.rb��URL��)�����������μ�ˡ�ϡ�Web�����Ф�
#             ���顼�����Ĥ�夬��Τǡ��侩�Ǥ��ޤ��󡣾��mod_rewrite��
#             �Ȥ��ʤ����Τߤκǽ����ʤǤ���
#
#               <Files ~ "^([0-9]{4}|[0-9]{6}|[0-9]{8}).html$">
#                   ErrorDocument 404 your_URL_of_index.rb
#               </Files>
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#

def anchor( s )
	if /^(\d+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			"#$1.html##$2"
		else
			"#$1.html"
		end
	else
		""
	end
end

