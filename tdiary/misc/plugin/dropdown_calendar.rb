# dropdown_calendar.rb $Revision: 1.3 $
#
# calendar: ����������ɥ�åץ�����ꥹ�Ȥ��֤�������ץ饰����
#   �ѥ�᥿: �ʤ�
#

@dropdown_calendar_label = '��������' unless @resource_loaded

def calendar
	result = %Q[<form method="get" action="#{@index}">\n]
	result << %Q[<div class="calendar">#{@options['dropdown_calendar.label'] || @dropdown_calendar_label}\n]
	result << %Q[<select name="date">\n]
	@years.keys.sort.reverse_each do |year|
		@years[year.to_s].sort.reverse_each do |month|
			result << %Q[<option value="#{year}#{month}">#{year}-#{month}</option>\n]
		end
	end
	result << "</select>\n"
	result << %Q[<input type="submit" value="Go">\n]
	result << "</div>\n</form>"
end
