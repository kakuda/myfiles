# jdate.rb $Revision: 1.1 $
#
#��%J�פ����ܸ������̾��Ф�
#    plugin������������ư��롣
#    ���եե����ޥåȤʤɤǡ�%J�פ���ꤹ��Ȥ��������ܸ�������ˤʤ�
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
unless Time::new.respond_to?( :strftime_jdate_backup ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Time
		   alias strftime_jdate_backup strftime
		   JWDAY = %w(�� �� �� �� �� �� ��)
		   def strftime( format )
		      strftime_jdate_backup( format.gsub( /%J/, JWDAY[self.wday] ) )
		   end
		end
	MODIFY_CLASS
end
