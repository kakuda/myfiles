=begin
= ��������ŷ���ץ饰����((-$Id: weather.rb,v 1.5 2004/05/15 05:44:51 zunda Exp $-))
��������ŷ���򡢤�������������ǽ�˹���������˼���������¸�������줾��
�����������ξ�����ɽ�����ޤ���

== ������ˡ
���Υե�����κǿ��Ǥϡ�
((<URL:http://zunda.freeshell.org/d/plugin/weather.rb>))
�ˤ���ޤ���

== �Ȥ���
=== ���󥹥ȡ�����������ˡ
���Υե������plugin�ǥ��쥯�ȥ�˥��ԡ����Ƥ������������������ɤ�
EUC-JP�Ǥ���

���ˡ�tdiary.conf���Խ����뤫��WWW�֥饦������tDiary��������̤���֤���
����ŷ���פ�����ǡ�ŷ���ǡ����򤤤������Ƥ���URL�����ꤷ�Ƥ���������
tdiary.conf���Խ�������ˤϡ�@options['weather.url']�����ꤷ�Ƥ����� 
����ξ��������򤷤����ˤϡ�tDiary��������̤Ǥ����꤬ͥ�褵��ޤ���

�㤨�С� NOAA National Weather Service�����Ѥ�����ˤϡ�
((<URL:http://weather.noaa.gov/>))���顢Select a country...�ǹ�̾������
��Go!�ܥ���򲡤������˴�¬����������Ǥ������������λ�ɽ�����줿�ڡ���
��URL���㤨�С�
  @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
�Ƚ񤤤Ƥ���������������Ǥ�����إ�ݡ���((-�ɤ��ˤ�������-))��ŷ��
����Ͽ����ޤ�������������Ѥ����¤���Ƥ����礬����ޤ��Τǡ����Τ�
����WWW�ڡ�����������������ʤ��褦����դ��Ƥ���������

����ˡ����������Υ����ॾ�����Ѳ������ǽ�����������ϡ����Υ����ॾ��
���@options['weather.tz']�����Ķ��ѿ�TZ�����ꤷ�Ƥ������Ȥ򤪴��ᤷ 
�ޤ�������ˤ�äơ����������ۤ�����⡢ŷ���ǡ����������Υ����ॾ���� 
��ŷ����ɽ����³���뤳�Ȥ��Ǥ��ޤ���tdiary.conf�����ꤹ����ϡ��㤨��
����ɸ����ξ��ϡ�
  @options['weather.tz'] = 'Japan'
�����ꤷ�Ƥ���������

����ǡ�������������������٤ˡ����ꤷ��URL����ŷ���ǡ�����������ơ�
ɽ������褦�ˤʤ�Ϥ��Ǥ���ŷ���ϡ�
  <div class="weather"><span class="weather">hh:mm����<a href="������URL">ŷ��(����)</a></span></div>
�Ȥ��������Ǥ��줾������������ξ��ɽ������ޤ���ɬ�פʤ�С�CSS���Խ�
���Ƥ���������
  div.weather {
    text-align: right;
    font-size: 75%;
  }
�ʤɤȤ��Ƥ����Ф����Ǥ��礦��

�����˻��Ѥ��Ƥ���WWW�����С����饵���С��θ��¤�WWW�ڡ����α������Ǥ���
ɬ�פ�����ޤ����Ķ��ѿ�TZ���ѹ������礬����ޤ��Τǡ�secure�⡼�ɤǤ�
�Ȥ��ޤ���mod_ruby�Ǥ�ư��Ϻ��ΤȤ����ǧ���Ƥ��ޤ���

�ǥե���ȤǤϡ�����ü������������줿���ˤ�ŷ����ɽ�����ʤ��褦�ˤʤ�
�Ƥ��ޤ������Ӥ���Ǥ�ŷ����ɽ�����������ˤϡ�������̤������ꤹ�뤫��
tdiary.conf��
  @options['weather.show_mobile'] = true
����ꤷ�Ƥ���������

=== ��¸�����ŷ���ǡ����ˤĤ���
ŷ���ǡ����ϡ�
* �񤤤Ƥ����������դȸ��ߤ����դ����פ���
* ��������ŷ���ǡ������ޤ���������Ƥ��ʤ���������μ������˥��顼�����ä�
���ˡ���������ޤ���

ŷ���ǡ����ϡ�@options['weather.dir']�����ꤷ���ǥ��쥯�ȥ꤫��
@cache_path/weather/ �ǥ��쥯�ȥ�ʲ��ˡ�ǯ/ǯ��.weather �Ȥ����ե��� ��
̾����¸����ޤ������ֶ��ڤ�Υƥ����ȥե�����Ǥ��Τ�ɬ�פ˱������Խ� 
���뤳�Ȥ��Ǥ��ޤ������֤ο����Ѥ��Ƥ��ޤ�ʤ��褦�˵���Ĥ����Խ����Ƥ�
���������ե����ޥåȤξܺ٤ϡ�Weather.to_s�᥽�åɤ򻲾Ȥ��Ƥ���������

ŷ���ǡ����ˤϡ��ǡ����μ������郎��Ͽ����Ƥ��ޤ����ޤ����ǡ����μ�����
��������줿��ŷ���ι������郎��Ͽ����Ƥ��뤳�Ȥ⤢��ޤ��������λ���
�ϡ�����ɸ���(UNIX����)��ľ����Ƶ�Ͽ����Ƥ��ơ�������ɽ��������˸���
�����ľ���Ƥ��ޤ������Τ��ᡢŷ����Ͽ�������Υ����ॾ����ȡ�ŷ����ɽ
��������Υ����ॾ���󤬰ۤʤäƤ��ޤ��ȡ��㤨��ī��ŷ�����ä���Τ�ͼ��
��ŷ���Ȥ���ɽ������Ƥ��ޤ����Ȥˤʤ�ޤ���������ɤ��ˤϡ��㤨�С�
  @options['weather.tz'] = 'Japan'
�Ȥ������ץ��������ꤷ�ơ��ǡ����˥����ॾ�����Ͽ����褦�ˤ��Ƥ���
������tdiary.conf�ʤɤǡ�
  ENV['TZ'] = 'Japan'
�ʤɤȤ��ƴĶ��ѿ�TZ�����ꤹ�뤳�ȤǤ�Ʊ�ͤθ��̤������ޤ����Ķ��ѿ���
���ꤷ�����ϡ�tDiary���Τ�ư��˱ƶ�������ޤ��Τ�α�դ��Ƥ���������

�ʤ���1.1.2.19����������ΥС�������weather.rb�Ǥϥ����ॾ����ξ���
ŷ���ǡ����˵�Ͽ����Ƥ��ޤ��󡣤�����Ǥ�����ɬ�פʤ�С��ե�������Խ�
���ơ������ॾ���������ɲä��Ƥ�����������Ͽ�ե�����ϡ��ǥե���ȤǤϡ�
  .../cache/weather/2003/200301.weather
�ʤɤˤ���ޤ���������URL�μ��ο�����UNIX����Ǥ��Τǡ������³���ơ���
����Ĥȡ�Japan�ʤɥ����ॾ����򼨤�ʸ��������Ϥ��Ƥ����������ǡ���
�������˥��顼���ʤ���С����θ売�ĤΥ��֤�³���ơ�ŷ���Υǡ�������Ͽ��
��Ƥ���Ϥ��Ǥ���

=== ���ץ����
==== ɬ�����꤬ɬ�פʹ���
: @options['weather.url']
  ŷ���ǡ�����������WWW�ڡ�����URL��
    @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
  �ʤɡ�����������Ѥ����¤���Ƥ����礬����ޤ��Τǡ����Τ褦��WWW
  �ڡ�����������������ʤ��褦����դ��Ƥ����������֥饦���������ꤷ��
  ���Ϥ����餬ͥ�褵��ޤ���

==== ���ꤷ�ʤ��Ƥ⤤������
: @options['weather.show_mobile'] = false
  true�ξ��ϡ�����ü������Υ��������ξ��ˡ�i_html_string����������
  ��CHTML��ɽ�����ޤ���false�ξ��ϡ�����ü������Υ��������ξ��ˤ�ŷ
  ����ɽ�����ޤ��󡣥֥饦���������ꤷ�����Ϥ����餬ͥ�褵��ޤ���
  
: @options['weather.tz']
  �ǡ���������������Υ����ॾ���󡣥��ޥ�ɥ饤�����㤨�С�
    TZ=Japan date
  ��¹Ԥ������������郎ɽ�������ʸ��������ꤷ�Ƥ���������Linux�Ǥϡ�
  /usr/share/zoneinfo�ʲ��Υե�����̾����ꤹ��Ф����Ϥ��Ǥ����֥饦��
  �������ꤷ�����Ϥ����餬ͥ�褵��ޤ������Υ��ץ���󤬻��ꤵ��Ƥ�
  �ʤ���硢�Ķ��ѿ�TZ�����ꤵ��Ƥ���Ф����ͤ���Ѥ��ޤ��������Ǥʤ�
  ��Х����ॾ����ϵ�Ͽ���ޤ���
   
  ŷ���ǡ����˥����ॾ���󤬵�Ͽ����Ƥ��ʤ����ϡ��⤷���������Υ�����
  �������ѹ����줿���˰㤦�����ɽ�����뤳�Ȥˤʤ�ޤ���
  
  ���դ�Ƚ��ʤɡ�ŷ���ǡ����ε�Ͽ�ʳ��λ���δ����ˤϡ��������ΤΥ�����
  �������Ѥ����ޤ���

: @options['weather.oldest'] = 21600
  ����줿�ǡ����������Υ��ץ����(��)���Ť����ˤϡ�ŷ���μ������顼
  �ˤʤꡢ���������ι����ǺƤӥǡ�����������褦�Ȥ��ޤ����ǥե���Ȥ�6
  ����(21600��)�Ǥ������Υ��ץ����nil�����ꤵ��Ƥ�����ˤϡ��ɤ��
  �˸Ť��ǡ����Ǥ��������ޤ���

: @options['weather.show_error']
  �ǡ����������˥��顼�����ä����ˤ����������ɽ�����������ˤ�true��
  ���ޤ����ǥե���ȤǤ�ɽ�����ޤ���

: @options['weather.dir']
  �ǡ�������¸��ꡣ�ǥե���Ȥϰʲ����̤ꡣ
    "#{@cache_path}/weather/"
  ���β��ˡ�ǯ/ǯ��.weather �Ȥ����ե����뤬����ޤ��������
  @data_path��Ʊ���ˤ���ȡ������Υǡ�����Ʊ���ǥ��쥯�ȥ��ŷ���Υǡ���
  ����¸�Ǥ��뤫�⤷��ޤ���

: @options['weather.items']
  WWW�ڡ����������������ܡ��ǥե���Ȥϡ���������������������
  parse_html�����������̾�򥭡�����Ͽ�������̾���ͤȤ����ϥå���Ǥ���
  www.nws.noaa.gov�Υե����ޥåȤ˹�碌�ơ�¿����ñ�̤���ư�ˤ��Ѥ����
  ��褦�ˤ��Ƥ���ޤ���������ѹ�������ˤϡ�parse_html�᥽�åɤ���
  ������ɬ�פ����뤫�⤷��ޤ���

: @options['weather.header']
  HTTP�ꥯ�����ȥإå����ɲä�����ܤΥϥå���
    @options['weather.header'] = {'Accept-language' => 'ja'}
  �ʤɡ�((-Accept-language�ˤ�äƼ��������������٤륵���Ȥ⤢��ޤ���-))
  �ǥե���ȤǤ��ɲäΥإå����������ޤ���

== ŷ���������ˤĤ���
NWS����Υǡ����ϱѸ�Ǥ��Τǡ�Ŭ�������ܸ��ľ���Ƥ�����Ϥ���褦�ˤ�
�Ƥ���ޤ��������ϡ�WeatherTranslator�⥸�塼��ˤ�äƤ��ơ��Ѵ�ɽ�ϡ�
Weather���饹�ˡ�Words_ja�Ȥ�����������Ȥ���Ϳ���Ƥ���ޤ���

���äϤޤ��ޤ���ʬ�ǤϤʤ��Ȼפ��ޤ����Τ�ʤ�ñ��ϱѸ�Τޤ�ɽ�������
���Τǡ�Words_ja��Ŭ���ɲä��Ƥ���������
((<URL:http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?weather%2Erb>))
�˽񤤤Ƥ����ȡ����Τ������۸����ɲä���뤫�⤷��ޤ���

== �٤�������
ŷ���ǡ����������乥�ߤ˹��ơ��ʲ��Υ᥽�åɤ��ѹ����뤳�Ȥǡ����� 
������꤬�Ǥ��ޤ���

=== ɽ���˴ؤ�����
�ǥե���ȤǤϡ�ŷ���ǡ����ϡ�HTML_START��HTML_END�����ꤵ��Ƥ���ʸ�� 
��ǰϤޤ�ޤ���div��span�Υ��饹���ѹ�������ˤϡ��������ѹ������ 
���ǽ�ʬ�Ǥ�������ʾ���ѹ���ɬ�פʾ��ϰʲ����ѹ����Ƥ���������

: Weather.html_string
  @data[item]�򻲾Ȥ��ơ�ŷ����ɽ������HTML���Ҥ��äƤ���������

: Weather.error_html_string
  �ǡ����������顼�����ä����ˡ�@error�򻲾Ȥ��ƥ��顼��ɽ������HTML��
  �Ҥ��äƤ���������

����ü������α����κݤˤϡ�
  @options['weather.show_mobile'] = true
�ξ��ˤϡ��嵭������ˡ����줾��I_HTML_START��I_HTML_END��
Weather.i_html_string���Ȥ��ޤ������顼��ɽ���ϤǤ��ޤ���

=== ŷ���ǡ����μ����˴ؤ�����
: Weather.parse_html( html, items )
  ((|html|))ʸ�������Ϥ��ơ�((|items|))�ϥå���˽��ä�@data[item]����
  �����Ƥ���������((|items|))�ˤ�@optins['weather.items']�ޤ���
  Weather_default_items����������ޤ����֤��ͤ����Ѥ���ޤ��󡣥ơ��֥� 
  ���Ѥ���ŷ�����󸻤ʤ�С����Υ᥽�åɤ򤢤ޤ��¤���ʤ��ǻȤ��뤫�� 
  ����ޤ���

== �ޤ����٤�����
* ŷ���˱��������������ɽ�� -�ɤ��������

== �ռ�
��������ŷ���ץ饰����Υ����ǥ������󶡤��Ƥ������ä�hsbt���󡢼����Υ�
��Ȥ��󶡤��Ƥ������ä�zoe����˴��դ��ޤ����ޤ���NOAA�ξ�����󶡤���
�������ä�kotak����˴��դ��ޤ���

The author appreciates National Weather Service
((<URL:http://weather.noaa.gov/>)) making such valuable data available
in public domain as described in ((<URL:http://www.noaa.gov/wx.html>)).

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.
=end

=begin
== Instance variables
=end
@weather_plugin_name = '��������ŷ��'

=begin
== Classes and methods
=== WeatherTranslator module
We want Japanese displayed in a diary written in Japanese.

--- Weather::Words_ja
    Array of arrays of a Regexp and a Statement to be executed.
    WeatherTranslator::S.tr accepts this kind of hash to translate a
    given string.
=end

class Weather
	Words_ja = [
		[%r[\A(.*)/(.*)], '"#{S.new( $1 ).translate( table )}/#{S.new( $2 ).translate( table )}"'],
		[%r[\s*\b(greater|more) than (-?[\d.]+\s*\S*)\s*]i, '"#{S.new( $2 ).translate( table )}�ʾ�"'],
		[%r[^(.*?) with (.*)$]i, '"#{S.new( $2 ).translate( table )}�����#{S.new( $1 ).translate( table )}"'],
		[%r[^(.*?) during the past hours?$]i, '"ľ���ޤ�#{S.new( $1 ).translate( table )}"'],
		#[%r[\s*\b([\w\s]+?) in the vicinity]i, '"���դ�#{S.new( $1).translate( table )}"'],
		[%r[\s*\bin the vicinity\b\s*]i, '""'],
		# ... in the vicinity��̵�뤵���褦�ˤʤäƤ��ޤ������줬�ߤ������ϡ�
		# ��Υ����ȥ����Ȥ���Ƥ���ԤΥ����Ȥ򳰤��Ƥ���������
		[%r[\s*\bpatches of\b\s*]i, '""'],
		[%r[\s*\bdirection variable\b\s*]i, '"����"'],
		[%r[\s*(-?[\d.]+)\s*\(?F\)?], '"�ڻ�#{$1}��"'],
		[%r[\s*\bmile(\(?s\)?)?\s*]i, '"�ޥ���"'],
		[%r[\s*\b(mostly |partly )clear\b\s*]i, '"��"'],
		[%r[\s*\bclear\b\s*]i, '"����"'],
		[%r[\s*\b(mostly |partly )?cloudy\b\s*]i, '"��"'],
		[%r[\s*\bovercast\b\s*]i, '"��"'],
		[%r[\s*\blight snow showers?\b\s*]i, '"�ˤ狼��"'],
		[%r[\s*\blight snow\b\s*]i, '"����"'],
		[%r[\s*\blight drizzle\b\s*]i, '"����"'],
		[%r[\s*\blight rain showers?\b\s*]i, '"�夤�ˤ狼��"'],
		[%r[\s*\bheavy rain showers?\b\s*]i, '"�����ˤ狼��"'],
		[%r[\s*\bheavy rain\b\s*]i, '"�뱫"'],
		[%r[\s*\b(rain )?showers?\b\s*]i, '"�ˤ狼��"'],
		[%r[\s*\bdrizzle\b\s*]i, '"���̤���"'],
		[%r[\s*\blight rain\b\s*]i, '"̸��"'],
		[%r[\s*\brain\b\s*]i, '"��"'],
		[%r[\s*\bmist\b\s*]i, '"��"'],
		[%r[\s*\bhaze\b\s*]i, '"��"'],
		[%r[\s*\b(partial )?(freezing )?fog\b\s*]i, '"̸"'],
		[%r[\s*\bsnow\b\s*]i, '"��"'],
		[%r[\s*\bthunder( storm)?\b\s*]i, '"��"'],
		[%r[\s*\blightning\b\s*]i, '"���"'],
		[%r[\s*\bsand\b\s*]i, '"����"'],
		[%r[\s*\bcumulonimbus clouds\b\s*]i, '"�����"'],
		[%r[\s*\bcumulus clouds\b\s*]i, '"�ѱ�"'],
		[%r[\s*\btowering\b\s*]i, '""'],
		[%r[\s*\bobserved\b\s*]i, '""'],
		[%r[\s*\bC\b\s*], '"��"'],
	].freeze
end

=begin
=== Weather class
Weather of a date.
--- Weather.html_string
--- Weather.error_html_string
      Returns an HTML fragment showing data or error, called from
      Weather.to_html.

--- Weather.i_html_string
      Returns a CHTML fragment to be shown on a mobile browser.
=end
class Weather

	def error_html_string
		%Q|#{HTML_START}��ŷ�����顼:<a href="#{@url}">#{CGI::escapeHTML( @error )}</a>#{HTML_END}|
	end

	# edit this method to define how you show the weather
	def html_string
		r = "#{HTML_START}"

		# time stamp
		if @tz then
			tzbak = ENV['TZ']
			ENV['TZ'] = @tz	# this is not thread safe...
		end
		if @data['timestamp'] then
			r << Time::at( @data['timestamp'].to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		else
			r << Time::at( @time.to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		end
		r << '����'
		if @tz then
			ENV['TZ'] = tzbak
		end

		# weather
		r << %Q|<a href="#{@url}">|
		if @data['weather'] then
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ).compact )
		elsif @data['condition'] then
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ).compact )
		end

		# temperature
		if @data['temperature(C)'] and t = @data['temperature(C)'].scan(/-?[\d.]+/)[-1] then
			r << %Q| #{sprintf( '%.0f', t )}��|
		end

		r << "</a>#{HTML_END}\n"
	end

	# edit this method to define how you show the weather for a mobile agent
	def i_html_string
		r = ''

		# weather
		if @data['weather'] then
			r << "#{I_HTML_START}"
			r << %Q|<A HREF="#{@url}">|
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ).compact )
			r << "</A>#{I_HTML_END}\n"
		elsif @data['condition'] then
			r << "#{I_HTML_START}"
			r << %Q|<A HREF="#{@url}">|
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ).compact )
			r << "</A>#{I_HTML_END}\n"
		end

	end
end

# www configuration interface
def weather_configure_html( conf )
	<<-HTML
	<h3 class="subtitle">��������ŷ���ץ饰����</h3>
	<p>��������ŷ���򡢤�������������ǽ�˹���������˼���������¸����
		���줾������������ξ�����ɽ�����ޤ���</p>
	<h4>ŷ���ǡ���</h4>
	<p>��������ŷ�����㤨��NOAA National Weather Service�����Ѥ�����ˤϡ�
		<a href="http://weather.noaa.gov/">NOAA National Weather Service</a>
		���顢Select a country...�ǹ�̾�������Go!�ܥ���򲡤���
		���˴�¬����������Ǥ���������
		�����ơ����λ�ɽ�����줿�ڡ�����URL�򡢰ʲ��˵������Ƥ���������</p>
	<p><input name="weather.url" value="#{conf['weather.url']}" size="60"></p>
	<p>���������Υ����ॾ�����Ѳ������ǽ�����������ϡ�
		���Υ����ॾ�����Ͽ���Ƥ������Ȥ򤪴��ᤷ�ޤ���
		����ˤ�äơ����������ۤ�����⡢
		ŷ���ǡ����������Υ����ॾ�����ŷ����ɽ����³���뤳�Ȥ��Ǥ��ޤ���</p>
	<p>�����ॾ�����Ͽ����ˤϡ��㤨������ɸ����ξ��ˤϡ�
		tdiary.rb��Ʊ���ǥ��쥯�ȥ�ˤ���tdiary.conf�ˡ�
		ENV['TZ'] = 'Japan'�ʤɤȽ�­������
		�ʲ��ˡ�Japan�ȵ������Ƥ���������</p>
	<p><input name="weather.tz" value="#{conf['weather.tz']}"></p>
	<h4>�������äؤ�ɽ��</h4>
	<p>������������Ǥ���������</p>
	<p><select name="weather.show_mobile">
		<option value="true"#{' selected'if conf['weather.show_mobile']}>
		�������äˤ⺣����ŷ����ɽ������
		<option value="false"#{' selected'unless conf['weather.show_mobile']}>
		�������äˤϺ�����ŷ����ɽ�����ʤ�
	</select></p>
	<h4>����¾������</h4>
	<p>����¾�ˤ⤤���Ĥ�tdiary.conf��������Ǥ�����ܤ�����ޤ���
		�ܤ����ϡ��ץ饰����Υե�����(weather.rb)��������������</p>
	HTML
end

