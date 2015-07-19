# comment_mail_qmail.rb $Revision: 1.7 $
#
# qmail��Ȥäƥĥå��ߤ�᡼����Τ餻��
#   ����������ư��롣
#
# Options:
#   ������̤������Ǥ�����(�ĥå��ߥ᡼��ϥץ饰������):
#     @options['comment_mail.enable']
#          �᡼������뤫�ɤ�������ꤹ�롣true(����)��false(����ʤ�)��
#          ̵�������false��
#     @options['comment_mail.header']
#          �᡼���Subject�˻Ȥ�ʸ���󡣿���ʬ�����������ʤ褦�˻��ꤹ�롣
#          �ºݤ�Subject�ϡֻ���ʸ����:����-1�פΤ褦�ˡ����դȥ������ֹ椬
#          �դ�������������ʸ������ˡ�%��³���ѻ������ä���硢�����
#          ���եե����ޥåȻ���򸫤ʤ����Ĥޤ�����աפ���ʬ��
#          ��ưŪ���ղä���ʤ��ʤ�(�������ֹ���ղä����)��
#          ̵������ˤ϶�ʸ����
#     @options['comment_mail.receivers']
#          �᡼������륢�ɥ쥹ʸ���󡣥���ޤǶ��ڤä�ʣ������Ǥ��롣
#          ̵������ˤ�����ɮ�ԤΥ��ɥ쥹�ˤʤ롣
#  
#   tdiary.conf�ǤΤ߻���Ǥ�����:
#     @options['comment_mail.qmail']
#          qmail_inject���ޥ�ɤΥѥ�����ꤹ�롣
#          ̵������ˤϡ�'/var/qmail/bin/qmail-inject'�ס�
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text, to )
	begin
		qmail = @conf['comment_mail.qmail'] || '/var/qmail/bin/qmail-inject'
		open( "|#{qmail} -f #{@conf.author_mail.untaint} #{to.join(' ')}", 'w' ) do |o|
			o.write( text )
		end
	rescue
		$stderr.puts $!
	end
end

add_update_proc do
	comment_mail_send if @mode =~ /^(comment|trackbackreceive)$/
end

add_conf_proc( 'comment_mail', comment_mail_conf_label ) do
	comment_mail_basic_setting
	comment_mail_basic_html
end

