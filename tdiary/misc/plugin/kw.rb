# kw.rb $Revision: 1.8 $
#
# kw: keyword link generator
#   Parameters:
#     keyword: keyword or InterWikiName (separated by ':').
#     name: anchor string (optional).
#
# @options['kw.dic']
#   array of dictionary table array. an item of array is:
#
#       [key, URL, style]
#
#   key:   nil or string of key.
#          If keyword is 'foo', it has key nil.
#          If keyword is 'google:foo', it has key 'google'.
#   URL:   the URL for link. '$1' is replace by keyword.
#   style: encoding style as: 'euc-jp', 'sjis', 'jis' or nil.
#
#   if there isn't @options['kw.dic'], the plugin links to google.
#
# @options['kw.show_inter']
#   Show InterWikiName.
#   If this options is true, the keyword 'google:foo' shows 'google:foo'.
#   But it is false, that shows only 'foo'.
#   The default of this option is true.
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#

def kw_parse( str )
	kw_list = []
	str.each do |pair|
		k, u, s = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 3 )
		k = nil if k == '' or k == 'nil'
		s = nil if s != 'euc-jp' && s != 'sjis' && s != 'jis'
		kw_list << [k, u, s] if u
	end
	kw_list
end

def kw_generate_dic
	case @lang
	when 'en'
		kw_dic = {nil => ['http://www.google.com/search?q=$1', nil]}
	else
		kw_dic = {nil => ['http://www.google.com/search?ie=euc-jp&amp;q=$1', 'euc-jp']}
	end

	kw_list = []
	case @conf['kw.dic'].class.to_s
	when "String"
		kw_list = kw_parse( @conf['kw.dic'] )
	when "Array"
		kw_list = @conf['kw.dic']
	end
	kw_list.each do |pair|
		kw_dic[pair[0]] = pair[1..-1]
	end
	kw_dic
end

def kw( keyword, name = nil )
	@kw_dic = kw_generate_dic unless @kw_dic
	show_inter = @options['kw.show_inter'] == nil ? true : @options['kw.show_inter']

	inter, key = keyword.split( /:/, 2 )
	unless key then
		inter = nil
		key = keyword
	end
	keyword = key unless show_inter
	name = keyword unless name
	begin
		key = CGI::escape( case @kw_dic[inter][1]
			when 'euc-jp'
				#NKF::nkf( '-e', key )
				key
			when 'sjis'
				NKF::nkf( '-s', key )
			when 'jis'
				NKF::nkf( '-j', key )
			else # none
				key
		end )
	rescue NameError
		inter = nil
		retry
	end
	%Q[<a href="#{@kw_dic[inter][0].sub( /\$1/, key )}">#{name}</a>]
end

#
# config
#
unless @resource_loaded then
	def kw_label
		"������ɥץ饰����"
	end

	def kw_desc
		<<-HTML
		<h3>��󥯥ꥹ�Ȥλ���</h3>
		<p>����Υ����ȤؤΥ�󥯤򡢴�ñ�ʵ��Ҥ��������뤿��Υץ饰����(kw)�Ǥ���
		�֥��� URL ���󥳡��ɥ�������פȶ���Ƕ��ڤäƻ��ꤷ�ޤ����㤨�С�</p>
		<pre>google http://www.google.com/search?ie=euc-jp&amp;q=$1 euc-jp</pre>
		<p>�Ȼ��ꤹ��ȡ�</p>
		<pre>&lt;%=kw('google:tdiary')%&gt;</pre>
		<p>�Τ褦�������˽񤱤�google��tdiary�򸡺������󥯤ˤʤ�ޤ�
		(������ˡ�ϥ�������ˤ�ä��Ѥ��ޤ�)���ʤ���������nil����ꤹ��ȡ�
		��google:�פ���ʬ��񤫤ʤ����λ��꤬�Ǥ��ޤ���</p>
		HTML
	end
end

add_conf_proc( 'kw', kw_label ) do
	if @mode == 'saveconf' then
		kw_list = kw_parse( @conf.to_native( @cgi.params['kw.dic'][0] ) )
		if kw_list.empty? then
			@conf.delete( 'kw.dic' )
		else
			@conf['kw.dic'] = kw_list.collect{|a|a.join( ' ' )}.join( "\n" )
		end
	end
	dic = kw_generate_dic
	if dic[nil] then
		dic['nil'] = dic[nil]
		dic.delete( nil )
	end
	<<-HTML
	#{kw_desc}
	<p><textarea name="kw.dic" cols="70" rows="10">#{dic.collect{|a|a.flatten.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

