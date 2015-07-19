# ja/todo.rb $Revision: 1.2 $
#
# Japanese resources for todo.rb
#
# Copyright (c) 2001,2002,2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
# 

def todo_msg_today; "����"; end
def todo_msg_in_time(days); "����#{days}��"; end
def todo_msg_late(days); "#{days}���٤�"; end
def todo_config_label; "ToDo�Խ�"; end

add_conf_proc('ToDo', 'ToDo�ץ饰����') do
	saveconf_todo
	todo_init

	<<-HTML
	<h3 class="subtitle">�Ȥ���</h3>
	<p><a href="#{@update}?conf=header">�إå����եå�</a>��'&lt;%=todo%&gt;'���ɲä��Ʋ�������</p>
	<h3 class="subtitle">ToDo�Խ�</h3>
	<p>��Ԥ˰�Ĥ���ToDo�򵭽Ҥ��ޤ���ToDo�η�����</p>
	<pre>ͥ����[����] ���뤳��</pre>
	<p>�Ǥ�����ͥ���١פȡ֤��뤳�ȡפδ֤�1�İʾ�Υ��ڡ����Ƕ��ڤ�ޤ���</p>
	<p>ͥ���٤Ͼ�ά��ǽ�Ǥ���ͥ���٤���ꤹ�����1��99����������ꤷ�ޤ�������ʳ���ͥ���٤���ꤷ����硤����ToDo��̵�뤵��ޤ���</p>
	<p>���¤Ͼ�ά��ǽ�Ǥ������¤���ꤹ�����'['��']'�ǰϤ�褦�ˤ��Ƥ������������¤ǻ��ꤷ��ʸ�����ruby��<a href="http://www.ruby-lang.org/ja/man-1.6/?cmd=view;name=ParseDate">ParseDate�⥸�塼��</a>�ǲ��ϤǤ���С����¤ޤǤ������⤢�碌��ɽ�����ޤ���</p>
	<p><textarea name="todo.todos" cols="70" rows="15">#{@todos.join("\n")}</textarea></p>

	<h3 class="subtitle">ToDo�ꥹ�ȤΥ����ȥ�</h3>
	<p>ToDo�ꥹ�ȤΥ����ȥ����ꤷ�ޤ���������ꤷ�ʤ��ȡ�&quot;ToDo:&quot;�����Ѥ���ޤ���</p>
	<p><input name="todo.title" value="#{CGI::escapeHTML(@conf['todo.title']) if @conf['todo.title']}"></p>

	<h3 class="subtitle">ɽ������ToDo�η��</h3>
	<p>ɽ������ToDo�η����ɽ�����ޤ���������ꤷ�ʤ��ȡ�10�郎���ꤵ��ޤ���</p>
	<p>����<input name="todo.n" value="#{@conf['todo.n']}" size="3">��</p>
	HTML
end
# vim: ts=3
