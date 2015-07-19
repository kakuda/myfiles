#!/usr/local/bin/ruby -Ke

require 'open-uri'
require 'kconv'
require 'cgi'
require 'readline'

def get(input)
  if input.size > 10 then
    s = input.split(/[のにをもではが。、]/)
    input = s[rand(s.size)]
  end
  str = CGI::escape(input.toeuc)
  google = ''
  open("http://www.google.co.jp/search?num=50&q=#{str}"){ |f|
    google = f.read
  }

  r = google.scan(/[\n>．。 　]([^\n>！？．。]{10,100}。)/)
  r[rand(r.size)].to_s.sub(/^[」』のにをもではがと]/,'')
end

while buf = Readline::readline("> ", true)
  #puts "ぐぐるさん -> 「#{get(buf)}」"
  #puts "ぐぐるさん -> 「#{get(buf)}」".toeuc
  puts "ぐぐるさん -> 「#{get(buf)}」".toutf8
end
