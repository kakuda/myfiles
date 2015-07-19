=begin
= Ϣ�������ץ饰���� sn.rb $Revision: 1.3 $

== ����
	�����դ���������̤��ֹ��ɽ�����ޤ���

== �Ȥ���
	sn( number )
		number - ���������󥿤���ꤷ���ͤ˥��åȤ��ޤ���
	sn_anchorid

	sn()�᥽�åɤ������γ����դ��Ȥˡ�1����Ϥޤ��̤��ֹ��ɽ�����ޤ���

	sn_anchorid()�᥽�åɤϸ��ߤΥ��󥫡�id���ֹ��ɽ�����ޤ���
	sn_anchorid()�����ꥪ�ץ������Υ��������/�ĥå��ߥ��󥫡�
	�Ȥ��ƻ��ꤹ�뤳�Ȥˤ�äơ����Υ��������/�ĥå��ߥ��󥫡���
	URL�ȷ���դ������ͤ�ɽ�����뤳�Ȥ��Ǥ��ޤ���

== ����
	anchor()��zoe����number_anchor.rb�򻲹ͤ˺������ޤ�����

= Sequential number generator plugin
== Abstract
	Display sequential numbers for every date.

== Usage
	sn( number )
		number - Set the value of the internal counter to 'number'.
	sn_anchorid

		The sn() method displays sequential numbers starting at 1 for
		every date.

		The sn_anchorid() method displays a current number of the anchorid.
		If you use sn_anchorid() as a section/comment anchor in the setup
		option, you can display the number relevant to URL of
		the section/comment anchor.

== reference
	Original anchor() appeared in the number_anchor.rb by zoe-san.

== ����ˤĤ��� (Copyright notice)
	Copyright (c) 2003 SAKAMOTO Hideki <hs@on-sky.net>
	Distributed under the GPL
=end

=begin Changelog
2003-09-23 SAKAMOTO Hideki <hs@on-sky.net>
	* document corrected
2003-09-17 SAKAMOTO Hideki <hs@on-sky.net>
	* add add_body_leave_proc
2003-09-13 SAKAMOTO Hideki <hs@on-sky.net>
	* change @sn_section initialization: nil -> 0
	* delete @sn_section  clear line in sn()
	* add sn_anchorid method
2003-09-10 SAKAMOTO Hideki <hs@on-sky.net>
	* write English document
	* force to use anchor-id in section anchor
	* delete 'sn.use_anchorid' option
2003-08-29 SAKAMOTO Hideki <hs@on-sky.net>
	* first version
=end

add_body_enter_proc do |date|   
	@sn_count = 1
	@sn_idx = 0
	""
end

add_body_leave_proc do |date|   
	@sn_count = 1
	@sn_idx = 0
	""
end

alias :_orig_anchor_sn :anchor

def anchor( s )
	if /^(\d+)#?([pct])?(\d*)?$/ =~ s then
		if $2 then
			@sn_idx = $3.to_i
		end
	end
	_orig_anchor_sn(s)
end

def sn( number = nil )
	if number then
		@sn_count = number.to_i
	else
		number = @sn_count
	end
	@sn_count += 1
	%Q[#{'%d' % number}]
end
 
def sn_anchorid
	%Q[#{'%d' % @sn_idx}]
end
