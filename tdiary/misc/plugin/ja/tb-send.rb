# Japanese resource of tb-send.rb

@tb_send_ping_charset = @conf.encoding
@tb_send_label_url = 'TrackBack������URL'
@tb_send_label_section = 'TrackBack���륻�������'
@tb_send_label_no_section = '(������������ꤷ�ʤ�)'
@tb_send_label_current_section = '(�Ǹ���ɵ��������������)'
if @conf['tb.no_section'] then
	@tb_send_label_excerpt = '��ά(�������ʤ������ʸ����Ƭ���Ȥ��ޤ�)'
else
	@tb_send_label_excerpt = '��ά(�������ʤ�������򤷤�������������Ƭ���Ȥ��ޤ�)'
end
