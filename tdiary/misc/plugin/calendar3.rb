# calendar3.rb $Revision: 1.37 $
#
# calendar3: ����ɽ�����Ƥ����Υ���������ɽ�����ޤ���
#  �ѥ�᥿: �ʤ�
#
# tdiary.conf�ǻ��ꤹ�륪�ץ����:
#   @options['calendar3.show_todo']
#     �ѥ饰��դΥ��֥����ȥ�Ȥ����ǻ��ꤷ��ʸ���󤬰��פ�
#     ���Ĥ���������������ɽ���ξ�硤���Υѥ饰��դ����Ƥ�
#     ͽ��Ȥ���popup���롥
#
#   @options['calendar3.show_popup']
#     JavaScript�ˤ��popup��ɽ�����뤫�ɤ�����
#     ��ά�����ͤ�true�ʤΤǡ�ɽ���������ʤ����Τ�false�����ꤹ�롥
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
#
# sample CSS for calendar3
#
# .calendar-popup {
#         display: none;
#         text-align: left;
#         position: absolute;
#         border-style: solid;
#         border-width: 1px;
#         padding: 0 1ex 0 1ex;
# }
#
# .calendar-sunday {
#         color: red;
# }
#
# .calendar-saturday {
#         color: blue;
# }
#
# .calendar-weekday {
#         color: black;
# }
#
# .calendar-normal {
# }
#
# .calendar-day {
#         font-weight: bold;
# }
#
# .calendar-todo {
#         border-style: solid;
#         border-color: red;
#         border-width: 1px;
# }
#
=begin ChengeLog
2003-09-25 TADA Tadashi <sho@spc.gr.jp>
	* use @conf.shorten.

2003-03-25 Junichiro Kita <kita@kitaj.no-ip.com>
	* add css to navigation links to next, current, prev month.

2003-02-27 Junichiro Kita <kita@kitaj.no-ip.com>
	* @options['calendar.show_popup']

2003-01-07 Junichiro Kita <kita@kitaj.no-ip.com>
   * append sample css

2003-01-07 MURAI Kensou <murai@dosule.com>
	* modify javascript for popdown-delay

2002-12-20 TADA Tadashi <sho@spc.gr.jp>
	* use Plugin#apply_plugin.
=end

module Calendar3
	WEEKDAY = 0
	SATURDAY = 1
	SUNDAY = 2

	STYLE = {
		WEEKDAY => "calendar-weekday",
		SATURDAY => "calendar-saturday",
		SUNDAY => "calendar-sunday",
	}

	def make_cal(year, month)
		result = []
		1.upto(31) do |i|
			t = Time.local(year, month, i)
			break if t.month != month
			case t.wday
			when 0
				result << [i, SUNDAY]
			when 1..5
				result << [i, WEEKDAY]
			when 6
				result << [i, SATURDAY]
			end
		end
		result
	end

	def prev_month(year, month)
		if month == 1
			year -= 1
			month = 12
		else
			month -= 1
		end
		[year, month]
	end

	def next_month(year, month)
		if month == 12
			year += 1
			month = 1
		else
			month += 1
		end
		[year, month]
	end

	module_function :make_cal, :next_month, :prev_month
end

def calendar3
	return '' if bot?
	show_todo = @options['calendar3.show_todo']
	show_todo = Regexp.new(show_todo) if show_todo
	result = ''
	if @options.has_key? 'calendar3.erb'
		result << %Q|<p class="message">@options['calendar3.erb'] is obsolete!<p>|
	end

	if @mode == 'latest'
		date = Time.now
	else
		date = @date
	end
	year = date.year
	month = date.month
	day = date.day

	result << %Q|<span class="calendar-prev-month"><a href="#{@index}#{anchor "%04d%02d" % Calendar3.prev_month(year, month)}">&lt;&lt;</a></span>\n|
	result << %Q|<span class="calendar-current-month"><a href="#{@index}#{anchor "%04d%02d" % [year, month]}">#{"%04d/%02d" % [year, month]}</a>/</span>\n|
	#Calendar3.make_cal(year, month)[(day - num >= 0 ? day - num : 0)..(day - 1)].each do |day, kind|
	Calendar3.make_cal(year, month).each do |day, kind|
		date = "%04d%02d%02d" % [year, month, day]
		if @diaries[date].nil?
			result << %Q|<span class="calendar-normal"><a class="#{Calendar3::STYLE[kind]}">#{day}</a></span>\n|
 		elsif !@diaries[date].visible?
			todos = []
			if show_todo
				@diaries[date].each_section do |section|
					if show_todo === section.subtitle
						todos << CGI::escapeHTML(section.body_to_html).gsub(/\n/, "&#13;&#10;")
					end
				end
			end
			if todos.size != 0
				result << %Q|<span class="calendar-todo"><a class="#{Calendar3::STYLE[kind]}" title="#{day}����ͽ��:&#13;&#10;#{todos.join "&#13;&#10;"}">#{day}</a></span>\n|
			else
				result << %Q|<span class="calendar-normal"><a class="#{Calendar3::STYLE[kind]}">#{day}</a></span>\n|
			end
		else
			result << %Q|<span class="calendar-day" id="target-#{day}" onmouseover="popup(document.getElementById('target-#{day}'),document.getElementById('popup-#{day}'), document.getElementById('title-#{day}'));" onmouseout="popdown(document.getElementById('popup-#{day}'));">\n|
			result << %Q|  <a class="#{Calendar3::STYLE[kind]}" id="title-#{day}" title="|
			i = 1
			r = []
			if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
				@diaries[date].each_section do |section|
					if section.stripped_subtitle
						text = apply_plugin( section.stripped_subtitle_to_html, true )
						r << %Q|#{i}. #{text}|
					end
					i += 1
				end
			else
				@diaries[date].each_section do |section|
					if section.subtitle
						text = apply_plugin( section.subtitle_to_html, true )
						r << %Q|#{i}. #{text}|
					end
					i += 1
				end
			end
			result << r.join("&#13;&#10;")
			result << %Q|" href="#{@index}#{anchor date}">#{day}</a>\n|
			if @calendar3_show_popup
				result << %Q|  <span class="calendar-popup" id="popup-#{day}">\n|
				i = 1
				if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
					@diaries[date].each_section do |section|
						if section.stripped_subtitle
							text = apply_plugin( section.body_to_html, true )
							subtitle = apply_plugin( section.stripped_subtitle_to_html )
							result << %Q|    <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}" title="#{CGI::escapeHTML( @conf.shorten( text ) )}">#{i}</a>. #{subtitle}<br>\n|
						end
						i += 1
					end
				else
					@diaries[date].each_section do |section|
						if section.subtitle
							text = apply_plugin( section.body_to_html, true )
							subtitle = apply_plugin( section.subtitle_to_html )
							result << %Q|    <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}" title="#{CGI::escapeHTML( @conf.shorten( text ) )}">#{i}</a>. #{subtitle}<br>\n|
						end
						i += 1
					end
				end
				result << %Q|  </span>\n|
			end
			result << %Q|</span>\n|
		end
	end
	result << %Q|<span class="calendar-next-month"><a href="#{@index}#{anchor "%04d%02d" % Calendar3.next_month(year, month)}">&gt;&gt;</a></span>\n|
	result
end

@calendar3_show_popup = true
if @options.has_key?('calendar3.show_popup')
	@calendar3_show_popup = @options['calendar3.show_popup']
end
if /w3m|MSIE.*Mac/ === ENV["HTTP_USER_AGENT"]
	@calendar3_show_popup = false
	add_header_proc do
    <<JAVASCRIPT
  <script type="text/javascript">
  <!--
  function popup(target,element,notitle) {
  }

  function popdown(element) {
  }
  // -->
</script>
JAVASCRIPT
	end
end
if @calendar3_show_popup
	add_header_proc do
    <<JAVASCRIPT
  <script type="text/javascript">
  <!--
  // http://www.din.or.jp/~hagi3/JavaScript/JSTips/Mozilla/
  // _dom : kind of DOM.
  //        IE4 = 1, IE5+ = 2, NN4 = 3, NN6+ = 4, others = 0
  _dom = document.all?(document.getElementById?2:1)
                     :(document.getElementById?4
                     :(document.layers?3:0));
  var _calendar3_popElement = null;
  var _calendar3_popCount = 0;

  if (document.compatMode){
    if (_dom==2 && document.compatMode=="CSS1Compat") _dom = 2.5;
  } // Win IE6

  function getLeft(div){
    result = 0;
    while (1){
      div = div.offsetParent;
      result += div.offsetLeft;
      if (div.tagName=="BODY") return result;
    }
  }

  function getTop(div){
    result = 0;
    while (1){
      div = div.offsetParent;
      result += div.offsetTop;
      if (div.tagName=="BODY") return result;
    }
  }

  function moveDivTo(div,left,top){
    if(_dom==4){
      div.style.left=left+'px';
      div.style.top =top +'px';
      return;
    }
    if(_dom==2.5 || _dom==2 || _dom==1){
      div.style.pixelLeft=left;
      div.style.pixelTop =top;
      return;
    }
    if(_dom==3){
      div.moveTo(left,top);
      return;
    }
  }

  function moveDivBy(div,left,top){
    if(_dom==4){
      div.style.left=div.offsetLeft+left;
      div.style.top =div.offsetTop +top;
      return;
    }
    if(_dom==2.5 || _dom==2){
      div.style.pixelLeft=div.offsetLeft+left;
      div.style.pixelTop =div.offsetTop +top;
      return;
    }
    if(_dom==1){
      div.style.pixelLeft+=left;
      div.style.pixelTop +=top;
      return;
    }
    if(_dom==3){
      div.moveBy(left,top);
      return;
    }
  }

  function getDivLeft(div){
    if(_dom==2.5) return div.offsetLeft+getLeft(div);
    if(_dom==4 || _dom==2) return div.offsetLeft;
    if(_dom==1)            return div.style.pixelLeft;
    if(_dom==3)            return div.left;
    return 0;
  }

  function getDivTop(div){
    if(_dom==2.5) return div.offsetTop+getTop(div);
    if(_dom==4 || _dom==2) return div.offsetTop;
    if(_dom==1)            return div.style.pixelTop;
    if(_dom==3)            return div.top;
    return 0;
  }

  function getDivWidth (div){
    if(_dom==4 || _dom==2.5 || _dom==2) return div.offsetWidth;
    if(_dom==1)            return div.style.pixelWidth;
    if(_dom==3)            return div.clip.width;
    return 0;
  }

  function getDivHeight(div){
    if(_dom==4 || _dom==2.5 || _dom==2) return div.offsetHeight;
    if(_dom==1)            return div.style.pixelHeight;
    if(_dom==3)            return div.clip.height;
    return 0;
  }

  function popup(target,element,notitle) {
    _calendar3_popCount++;
    popdownNow();
    if (navigator.appName=='Microsoft Internet Explorer') {
      moveDivTo(element,getDivLeft(target)+getDivWidth(target),getDivTop(target)+getDivHeight(target)*13/8);
    } else {
      moveDivTo(element,getDivLeft(target)+getDivWidth(target)/2,getDivTop(target)+(getDivHeight(target)*2)/3);
    }
    element.style.display="block";
    notitle.title="";
  }

  function popdown(element) {
    _calendar3_popElement=element;
    setTimeout('popdownDelay()', 2000);
  }

  function popdownDelay() {
    _calendar3_popCount--;
    if (_calendar3_popCount==0) {
      popdownNow();
    }
  }

  function popdownNow() {
    if (_calendar3_popElement!=null) {
      _calendar3_popElement.style.display="none";
      _calendar3_popElement=null;
    }
  }
  // -->
</script>
JAVASCRIPT
	end
end
# vim: set ts=3:
