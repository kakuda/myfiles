# Japanese resource of highlight.rb
#

def highlight_conf_label; '�ϥ��饤��'; end

def highlight_conf_html
	<<-HTML
	<h3 class="subtitle">�ϥ��饤�Ȥο�����</h3>
	<p>�����פ�����Υ��֥����ȥ��<span style="color: #{CGI::escapeHTML(@conf['highlight.color'])}; background: #{CGI::escapeHTML(@conf['highlight.background'])}">����ץ�</span>�Τ褦�˥ϥ��饤�Ȥ��ޤ���</p>

	<table>
		<tr>
			<th>�ϥ��饤�Ȥ�ʸ����</th>
			<td><input name="highlight.color" value="#{CGI::escapeHTML(@conf['highlight.color'])}"></td>
		</tr>
		<tr>
			<th>�ϥ��饤�Ȥ��طʿ�</th>
			<td><input name="highlight.background" value="#{CGI::escapeHTML(@conf['highlight.background'])}"></td>
		</tr>
	</table>
	HTML
end
