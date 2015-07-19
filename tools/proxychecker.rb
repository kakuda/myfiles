require 'open-uri'

def check_pandora(proxy)
  check_url = 'http://www.pandora.com/'
  puts "#{proxy}"
  begin
    open(check_url, :proxy => "http://#{proxy}") do |f|
      puts "get"
    end
  rescue
    puts "connect error"
  end
end

def get_proxies(url)
  puts url
  results = []
  html = URI(url).read
  proxies = html.scan(/proxy\(\d,'\d+','\d+','\d+','\d+',\d+\);/im)
  countries = html.scan(/<\/script>\n\t+<\/TD>\n\t+<TD>\n(.*?)<\/TD>\n\t+<TD>/im).flatten
  cn_array = countries[0].gsub(/\t/, '').gsub(/\n/, '').split('<BR>')
  cn_array.each_with_index do |c, i|
    if c == "US"
      /proxy\((\d),'(\d+)','(\d+)','(\d+)','(\d+)',(\d+)\);/ =~ proxies[i]
      if $1 == "1"
        results << "#{$2}.#{$3}.#{$4}.#{$5}:#{$6}"
      elsif $1 == "2"
        results << "#{$5}.#{$2}.#{$3}.#{$4}:#{$6}"
      elsif $1 == "3"
        results << "#{$4}.#{$5}.#{$2}.#{$3}:#{$6}"
      elsif $1 == "4"
        results << "#{$3}.#{$4}.#{$5}.#{$2}:#{$6}"
      end
    end
  end
  results
end

0.upto(3) do |n|
  proxies = get_proxies("http://www.proxyforest.com/proxy.htm?pages=#{n}")
  proxies.each do |p|
    check_pandora(p)
  end
end

