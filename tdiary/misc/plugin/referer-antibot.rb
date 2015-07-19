# referer-antibot.rb $Revision: 1.2 $
#
# �������󥸥�ν��BOT�ˤϡ������Υ�󥯸��פ򸫤��ʤ��褦�ˤ���
# ����ˤ�ꡢ̵�ط��ʸ�����ǥ�����������뤳�Ȥ�����(��ͽ�ۤ����)
# plugin�ǥ��쥯�ȥ������������ư���
#
# ���ץ����:
#   @options['bot']
#      �������åȤˤ�����BOT��User-Agent���ɲä�������
#      ̵�������["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]�Τߡ�
#
# �ʤ���disp_referrer.rb�ץ饰����ˤ�Ʊ���ε�ǽ���ޤޤ�Ƥ���Τǡ�
# disp_referrer��Ƴ���Ѥߤξ��ˤ������ɬ�פϤʤ�
#
# ---------
#
# This plugin hide Today's Link to search engin's robots.
# It may reduce nose marked by robots.
#
# disp_referrer.rb plugin has already this function. You don't
# need install this plugin with disp_referrer.rb.
#
# Options:
#    @options['bot']
#      An array of User-Agent of search engine's robots.
#      Default setting is ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"].
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Modified by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

# short referer
alias referer_of_today_short_antibot_backup referer_of_today_short
def referer_of_today_short( diary, limit )
	return '' if bot?
	referer_of_today_short_antibot_backup( diary, limit )
end

# long referer
alias referer_of_today_long_antibot_backup referer_of_today_long
def referer_of_today_long( diary, limit )
	return '' if bot?
	referer_of_today_long_antibot_backup( diary, limit )
end
