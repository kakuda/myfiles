=begin
= emptDiary��������((-$Id: README.rd,v 1.5 2003/11/06 09:43:46 zunda Exp $-))

== ����
((:emptDiary��������:))((-emptDiary��'empty line permitted tDiary style'
���ά������ΤǤ���Ĺ���ͤ���-))�ϡ�((:tDiary�� ������:))�˲ä��ơ��ץ�
������ΰ����˶���Ԥ������������Ǥ������Υ��������Ȥ��ȡ������򥻥�
������ʬ����ݤˡ�<%��%>�δ֤ζ���Ԥ�̵�뤷�Ƥ�館�ޤ���

�����˥ץ����ꥹ�Ȥʤɤ�񤯾��ˡ��ꥹ�Ȥ�����Ԥ�ޤ�ȡ�
((:tDiary�� ������:))�Ǥϥꥹ�Ȥ����椫�鼡�Υ��������ˤʤäƤ��ޤ��� 
����((:emptDiary��������:))�Ǥϡ��ץ饰����ΰ�������ζ����̵�뤹���
�ǡ��㤨��pre.rb�ץ饰����Υҥ��ɥ�����ȤȤ��ƥץ����ꥹ�Ȥ򵭽�
���뤳�Ȥǡ��ץ����ꥹ�Ȥ˲����ѹ���ʤ��������˥ꥹ�Ȥ�񤯤��Ȥ���
���ޤ���

((:emptDiary��������:))�κǿ��Ǥϡ�
((<URL:http://zunda.freeshell.org/d/misc/style/emptdiary/emptdiary_style.rb>))���顢
���Υե�����κǿ��Ǥϡ�
((<URL:http://zunda.freeshell.org/d/misc/style/emptdiary/README.rd>))��
�顢 ����Ǥ���Ǥ��礦��

�ޤ���pre.rb�κǿ��Ǥϡ�
((<URL:http://zunda.freeshell.org/d/plugin/pre.rb>))��������Ǥ���Ϥ���
����

== Usage
���Υ��������Ȥ��ˤϡ�
(1) emptdiary_style.rb �ե������tdiary/ �ǥ��쥯�ȥ�˥��ԡ����Ƥ���
    ������tdiary/ �ǥ��쥯�ȥ�ϡ�tdiary.rb �ե�����Τ���ȥåץǥ��쥯
    �ȥ�β��ˤ���ޤ���
(2) tdiary.conf�˰ʲ��ιԤ�񤤤Ƥ���������
      @style = 'emptDiary'

�����ϡ�((:tDiary��������:))�ȤۤȤ��Ʊ���褦�˽񤯤��Ȥ��Ǥ��ޤ���
HOWTO-write-tDiary.html�˽񤫤�Ƥ����̤ꡢ
* ����̵���ǻϤޤ�Ԥϡ�((:��������󥿥��ȥ�:))�ˤʤ�ޤ������ιԤˤϡ�
  ((:��������󥢥󥫡�:))���դ��ޤ���
* ((:��������󥿥��ȥ�:))��³���Ԥϡ�����((:���������:))�����Ƥˤʤ��
  ����
* ����Ԥˤ�äơ�����((:���������:))��ʬ����ޤ���
* ((:���������:))�κǽ�ιԤ�����<�ǻϤ�뤳�Ȥˤ�äơ�
  ((:��������󥿥��ȥ�:))��̵��((:���������:))���뤳�Ȥ��Ǥ��ޤ���

((:emptDiary��������:))�Ǥϡ��嵭�Υ롼��˲ä��ơ�
* <%��%>�˰Ϥޤ줿����Ԥϡ�����������ʬ�䤹��ݤ�̵�뤵��ޤ����Ĥޤꡢ
  ���륻�������ˡ�<%��%>�˰Ϥޤ줿����Ԥ�ޤ�뤳�Ȥ��Ǥ��ޤ���
* �����ѤȤ��ơ������ˤϡ�<%��%>��Ʊ�������줾��ڥ��ˤʤäƴޤޤ�Ƥ���
  ���Ȥ����ޤ���

�Ĥޤꡢpre.rb��Ȥäơ�
  ��������󥿥��ȥ�
  <p>��������������</p>
  <%=pre <<'_PRE'
  #include <stdio.h>

  /* �嵭�϶���� */
  int
  main (int argc, char *argv[])
  {
    puts ("Hello world.");
  }
  _PRE
  %>
�ʤɤȤ��������������뤳�Ȥ��Ǥ��ޤ���������䥢��ѡ�����ɤμ��λ�
�Ȥؤ��Ѵ��ϡ�pre.rb�ǹԤ��뤳�Ȥ���դ��Ƥ���������

== �ռ�
���Υ�������ϡ�((:tDiary��������:))��TdiarySection��TdiaryDiary��super
class�Ȥ��Ƽ�������Ƥ��ޤ������Τ褦�ʥե쥭���֥�ʥ��饹���󶡤����
���롢tdiary_style.rb�����Ԥ������˴��դ��ޤ���

== ���
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.                                                  
=end
=begin ChangeLog
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- first draft
=end
