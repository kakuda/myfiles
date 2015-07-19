require 'webrick'

include WEBrick

htpasswd = HTTPAuth::Htpasswd.new('dot.htpasswd')
htpasswd.set_passwd(nil, 'diaryuser', 'diarypass')

htpasswd.flush

htpasswd2 = HTTPAuth::Htpasswd.new('dot.htpasswd')
pass = htpasswd2.get_passwd(nil, 'diaryuser', false)
p pass == 'diarypass'.crypt(pass[0,2])
