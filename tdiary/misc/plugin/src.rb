# src.rb $Revision: 1.1 $
#
# src: �����ե��������������(HTML�����������դ�)
#   �ѥ�᥿:
#     file: �ե�����̾
#
def src( file )
	CGI::escapeHTML( File::readlines( file ).join )
end

#
# src_inline: �ƥ����Ȥ���������(HTML�����������դ�)
#
# �ѥ�᥿: �ƥ�����ʸ����
#
def src_inline( str )
	CGI::escapeHTML( str )
end

