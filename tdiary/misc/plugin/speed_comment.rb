# speed_comment.rb $Revision: 1.5 $
#
# spped_comment: �ǿ�������ɽ�����˴ʰפʥĥå��ߥե������ɽ������
#                plugin�ǥ��쥯�ȥ������������ư���ޤ���
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
=begin ChangeLog
2003-09-24 TADA Tadashi <sho@spc.gr.jp>
	* support cookie for name.
	* support conf_proc.

2002-03-24 TADA Tadashi <sho@spc.gr.jp>
	* suppress output in mobile mode. 

2002-03-12 TADA Tadashi <sho@spc.gr.jp>
	* support insert into @header.
=end

add_body_leave_proc do |date|
	if /latest|month/ =~ @mode and not @cgi.mobile_agent? then
		@conf['speed_comment.name_size'] = 20 unless @conf['speed_comment.name_size']
		@conf['speed_comment.body_size'] = 40 unless @conf['speed_comment.body_size']
		r = ""
		r << %Q[<div class="form"><form method="post" action="] + @index + %Q["><p>]
		r << %Q[<input type="hidden" name="date" value="] + date.strftime( '%Y%m%d' ) + %Q[">]
		r << %Q[<input type="hidden" name="mail" value="">]
		r << comment_name_label + %Q[: <input class="field" name="name" size="#{@conf['speed_comment.name_size']}" value="#{@cgi.cookies['tdiary'][0]}">]
		r << comment_body_label + %Q[: <input class="field" name="body" size="#{@conf['speed_comment.body_size']}">]
		r << %Q[<input type="submit" name="comment" value="] + comment_submit_label + %Q[">]
		r << %Q[</p></form></div>]
	else
		''
	end
end

unless @resource_loaded then
	def speed_comment_label
		'�ʰץĥå���'
	end

	def speed_comment_html
		<<-HTML
		<h3>�ʰץĥå��ߥե�����Υ�����</h3>
		<p>̾����: <input name="speed_comment.name_size" size="5" value="#{@conf['speed_comment.name_size'] || 20}"></p>
		<p>��ʸ��: <input name="speed_comment.body_size" size="5" value="#{@conf['speed_comment.body_size'] || 40}"></p>
		HTML
	end
end

add_conf_proc( 'speed_comment', speed_comment_label ) do
	if @mode == 'saveconf' then
		@conf['speed_comment.name_size'] = @cgi.params['speed_comment.name_size'][0].to_i
		@conf['speed_comment.name_size'] = 20 if @conf['speed_comment.name_size'] < 1
		@conf['speed_comment.body_size'] = @cgi.params['speed_comment.body_size'][0].to_i
		@conf['speed_comment.body_size'] = 40 if @conf['speed_comment.body_size'] < 1
	end
	speed_comment_html
end


