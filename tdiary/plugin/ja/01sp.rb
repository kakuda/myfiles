# Japanese resources of 01sp.rb $Revision: 1.4 $

=begin
= �ץ饰��������ץ饰����((-$Id: 01sp.rb,v 1.4 2003/10/09 15:26:44 zunda Exp $-))
Please see below for an English description.

== ����
�ɤΥץ饰�����Ȥ��Τ����Ӥޤ�

���Υץ饰�����00defaults.rb�μ����ɤޤ졢���Υץ饰���󼫿Ȥ��������
ǽ�ʥץ饰�����ɤޤ�ޤ������θ�˥ǥե���ȤΥѥ��ˤ���ץ饰������
�߹��ޤ�ޤ��Τǡ�Ʊ���᥽�åɤ�������Ƥ�����ˤϡ��ǥե���ȤΥѥ���
��Τ�ͭ���ˤʤ�ޤ���

== �Ȥ���
���Υץ饰�����plugin/�ǥ��쥯�ȥ�����֤��Ƥ���������

�ޤ���00defaults.rb�䤳�Υץ饰����ʤɡ����Ф�ɬ�פʥץ饰����ʳ��ϡ�
http�����С����鸫�����̤Υǥ��쥯�ȥ�˰ܤ��Ƥ����������ʲ�����Ǥϡ�
plugin�ǥ��쥯�ȥ�β���selectable�Ȥ����ǥ��쥯�ȥ���äƤ��ޤ���

�Ǹ�ˡ�tdiary.rb��Ʊ�����ˤ���tdiary.conf�ˡ�
  @options['sp.path'] = 'misc/plugin'
�ʤɤȡ�����Ǥ���ץ饰����Τ���ǥ��쥯�ȥ��tdiary.rb�Τ���ǥ��쥯
�ȥ꤫������Хѥ������Хѥ��ǻ��ꤷ�Ƥ���������

secure==true�������Ǥ�Ȥ��ޤ���

== ���ץ����
:@options['sp.path']
  'plugin/selectable'�ʤɤȡ�����Ǥ���ץ饰����Τ���ǥ��쥯�ȥ��
  tdiary.rb�Τ���ǥ��쥯�ȥ꤫������Хѥ������Хѥ��ǻ��ꤷ�Ƥ���������

:@options['sp.usenew']
  ���������󥹥ȡ��뤵�줿�ץ饰�����ǥե���ȤǻȤ��褦�ˤ������
  true�����ꤷ�Ƥ������������������󥹥ȡ��뤵�줿�ץ饰����򸡽Ф����
  �ϡ����˥ץ饰�������򤵤����Ǥ���

== TODO
���򤵤�Ƥ����ץ饰���󤬾õ�줿���ˤɤ����뤫�����ߤμ����Ǥϡ��ץ�
�������ɤ߹��߻��ˤ�̵�뤷�ơ���������򤷤ʤ��������˾ä��롣

== ����ˤĤ��� (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end


@sp_label = '�ץ饰��������'
@sp_label_description = '<p>�ɤΥץ饰�����Ȥ������򤷤ޤ���</p>'
@sp_label_please_select = '<p>ͭ���ˤ������ץ饰����˥����å����Ƥ����������ץ饰����Υե�����̾�򥯥�å�����ȥɥ�����Ȥ������뤫�⤷��ޤ��󡣤����ɲá��Խ����Ƥ��������͡�</p>'
@sp_label_new = '<h4>�����١������������</h4>'
@sp_label_used = '<h4>������</h4>'
@sp_label_notused = '<h4>�ٷ���</h4>'
@sp_label_noplugin = '<p>�����ǽ�ʥץ饰����Ϥ���ޤ���</p>'
