# ja/recent_trackback3.rb $Revision: 1.1 $
#
# Japanese resources for recent_trackback3.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
add_conf_proc('RecentTrackBack3', '�Ƕ��TrackBack') do
	saveconf_recent_trackback3
	recent_trackback3_init

	<<-HTML
	<h3 class="subtitle">ɽ������TrackBack�ο�</h3>
	<p>����<input name="recent_trackback3.n" value="#{@conf['recent_trackback3.n']}" size="3">��</p>
	<h3 class="subtitle">��TrackBack�֤���������ʸ����</h3>
	<p><input name="recent_trackback3.sep" value="#{CGI.escapeHTML(@conf['recent_trackback3.sep'])}" size="20"></p>
	<h3 class="subtitle">���եե����ޥå�</h3>
	<p>���ѤǤ���'%'ʸ���ˤĤ��Ƥ�<a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Ruby�Υޥ˥奢��</a>�򻲾ȡ�</p>
	<p><input name="recent_trackback3.date_format" value="#{CGI.escapeHTML(@conf['recent_trackback3.date_format'])}" size="40"></p>
	<h3 class="subtitle">��������HTML�Υƥ�ץ졼��</h3>
	<p>��TrackBack��ɤΤ褦��HTML��ɽ�����뤫����ꤷ�ޤ���</p>
	<textarea name="recent_trackback3.format" cols="70" rows="3">#{CGI.escapeHTML(@conf['recent_trackback3.format'])}</textarea>
	<p>�ƥ�ץ졼�����<em>$����</em>�Ϥ��줾��ʲ������Ƥ��֤��������ޤ���ɬ�פΤʤ���Τϻ��ꤷ�ʤ��Ƥ⹽���ޤ���</p>
	<dl>
		<dt>$1</dt><dd>����ǥå�����</dd>
		<dt>$2</dt><dd>����TrackBack��URL��</dd>
		<dt>$3</dt><dd>����TrackBack��excerpt��</dd>
		<dt>$4</dt><dd>TrackBack�������Υ�����̾�ȵ���̾��</dd>
		<dt>$5</dt><dd>TrackBack Ping�����������������եե����ޥåȡפǻ��ꤷ��������ɽ������ޤ���</dd>
	</dl>
	HTML
end
end
# vim: ts=3
