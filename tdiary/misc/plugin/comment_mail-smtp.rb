# comment_mail-smtp.rb $Revision: 1.8 $
#
# SMTP�ץ�ȥ����Ȥäƥĥå��ߤ�᡼����Τ餻��
#   ����������ư���
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
#     @options['comment_mail.smtp_host']
#     @options['comment_mail.smtp_port']
#          ���줾�졢�᡼�������˻Ȥ�SMTP�����ФΥۥ���̾�ȥݡ����ֹ档
#          ̵������Ϥ��줾���'localhost'�פȡ�25�ס�
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text, to )
	begin
		require 'net/smtp'
		host = @conf['comment_mail.smtp_host'] || 'localhost'
		port = @conf['comment_mail.smtp_port'] || 25
		Net::SMTP.start( host, port ) do |smtp|
			smtp.send_mail( text, @conf.author_mail.untaint, to )
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
