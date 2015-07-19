# ping.rb Japanese resources
begin
	require 'uconv'
	@ping_encode = 'UTF-8'
	@ping_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@ping_encode = @conf.encoding
	@ping_encoder = Proc::new {|s| s }
end

if /conf/ =~ @mode then
	@ping_label_conf = '��������'
	@ping_label_list = '������ꥹ��'
	@ping_label_list_desc = '�������Τ򤹤�ping�����ӥ���URL��1�ԤˤĤ�1�����Ϥ��Ƥ����������ʤ������ޤꤿ��������ꤹ��ȡ�����ǥ����ॢ���Ȥ��Ƥ��ޤ������Τ�ޤ���'
end

@ping_label_send = '�������������'
