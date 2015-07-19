# whatsnew.rb $Revision: 1.4 $
#
# ̾�Ρ�
# What's New�ץ饰����
#
# ���ס�
# ̤�ɤΥ��������˻��ꤷ���ޡ�����Ĥ��뤳�Ȥ��Ǥ��ޤ���
#
# �Ȥ�����
# tdiary.conf �� @section_anchor ����Ƭ�˰ʲ��Τ褦�� <%= whats_new %> ���ɲä��ޤ���
#
#   @section_anchor = '<%= whats_new %><span class="sanchor">_</span>'
#
# ����������̤��/���ɤˤ�ä� <%= whats_new %> ����ʬ�����餫�����
# �ꤷ���ޡ������֤��������ޤ����ǥե���ȤǤ�̤�ɥ��������Ǥ�
# "!!!NEW!!!"�����ɥ��������Ǥ� "" ��Ÿ������ޤ���
#
# ��Revision �� 1.1 �� whats_new.rb �������Ǥϡ�<span> �����
#     <%= whats_new %> ��ޤ��褦�˽񤤤Ƥ��ޤ�������sanchor�ǲ�����
#     ɽ������褦�ʥơ��ޤǤϡ�whats_new �ν��Ϥ� sanchor �β�������
#     �ʤäƤ��ޤ��Ȥ������꤬����ޤ�����
#     �����ѹ���ȼ�������ɻ��Υǥե���Ȥ� '' ���ѹ����ޤ�����
#
# �֤���������ʸ������ѹ����������� tdiary.conf ���
#
#   @options['whats_new.new_mark'] = '<img src="/Images/new.png" alt="NEW!" border="0">'
#   @options['whats_new.read_mark'] = '��'
#
# �Τ褦�˻��ꤷ�ޤ���
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@whats_new = {}.taint

def whats_new
	return apply_plugin( @whats_new[:read_mark] ) unless @cgi
	@whats_new[:section] += 1
	t = @whats_new[:current_date] + "%03d" % @whats_new[:section]
	if t > @whats_new[:this_time]
		@whats_new[:this_time] = t
	end
	# ���⤷���� cookie ��Ȥ�ʤ�����ξ��ϵ�ǽ���ʤ�
	return apply_plugin( @whats_new[:read_mark] ) if @whats_new[:last_time] == "00000000000"
	if t > @whats_new[:last_time]
		apply_plugin( @whats_new[:new_mark] )
	else
		apply_plugin( @whats_new[:read_mark] )
	end
end

add_body_enter_proc do |date|
	if @cgi
		@whats_new[:current_date] = Time::at(date).strftime('%Y%m%d')
		@whats_new[:section] = 0
		@whats_new[:last_time]
	end
	""
end

add_header_proc do
	if @cgi
		if @cgi.cookies['tdiary_whats_new'][0]
			@whats_new[:this_time] = @whats_new[:last_time] = @cgi.cookies['tdiary_whats_new'][0]
		else
			# ���ơ��⤷���� cookie �ϻȤ�ʤ�����
			@whats_new[:this_time] = @whats_new[:last_time] = "00000000000"
		end
		@whats_new[:new_mark] = @options['whats_new.new_mark'] || '!!!new!!!'
		@whats_new[:read_mark] = @options['whats_new.read_mark'] || ''
	end
	""
end

add_footer_proc do
	if @cgi.script_name
		if @whats_new[:this_time] > @whats_new[:last_time]
			cookie_path = File::dirname(@cgi.script_name)
			cookie_path += '/' if cookie_path !~ /\/$/
			cookie = CGI::Cookie::new({
				'name' => 'tdiary_whats_new',
				'value' => [@whats_new[:this_time]],
				'path' => cookie_path,
				'expires' => Time::now.gmtime + 90*24*60*60 
			})
			add_cookie(cookie)
		end
	end
	""
end
# vim: ts=3
