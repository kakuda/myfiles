=begin
= �������������ץ饰����((-$Id: search_control.rb,v 1.2 2003/10/13 15:15:43 zunda Exp $-))
���ܸ�꥽����

== ����
����ɽ�����ǿ�ɽ���ʤɤ��줾��ˤĤ���Google�ʤɤθ������󥸥�˥���ǥ�
�������Ƥ�餦���ɤ��������椷�ޤ���

== �Ȥ���
���Υץ饰�����plugin/�ǥ��쥯�ȥ�����֤��뤫���ץ饰��������ץ饰��
���ȤäƤ��Υץ饰�����ͭ���ˤ��Ƥ���������

������̤���֤������������פ򥯥�å����뤳�Ȥǡ��ɤ�ɽ���⡼�ɤǤɤΤ�
����ư�����Ԥ��뤫���ꤹ�뤳�Ȥ��Ǥ��ޤ����ǥե���ȤǤϡ�����ʬ��ɽ��
�Τߡ��������󥸥����Ͽ�����褦�ˤʤäƤ��ޤ���

�ºݤ˸��̤����뤫�ɤ����ϡ��������󥸥�Υ�ܥåȤ��᥿�������ᤷ�� 
����뤫�ɤ����ˤ����äƤ��ޤ���

secure==true�������Ǥ�Ȥ��ޤ���

== ����ˤĤ��� (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

* Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- no table in configuration view, thanks to Tada-san.

* Aug 26, 2003 zunda <zunda at freeshell.org>
- no nofollow
- English translation
=end ChangeLog

# configuration
@search_control_plugin_name = '������������'
@search_control_description_html = <<-'_HTML'
	<p>�᥿������Ȥäơ��������󥸥�Υ�ܥåȤˡ�
		;ʬ�ʥڡ����Υ���ǥå�������ʤ��褦�ˤ��ꤤ���Ƥߤޤ���
		����ǥå������ä��ߤ���ɽ�������˥����å��򤷤Ƥ���������</p>
	_HTML
@search_control_categorirs = [
	[ '�ǿ�', 'latest' ], [ '����ʬ', 'day' ], [ '���ʬ', 'month' ],
	[ 'Ĺǯ', 'nyear' ], [ '���ƥ��꡼', 'category' ]
]
