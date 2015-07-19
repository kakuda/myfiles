#!/usr/bin/env ruby

amazon_url = /<a href="http:\/\/www.amazon.(?:com|co.jp)\/(?:exec\/obidos\/ASIN|gp\/product)\/([^\/]+)\/"/
dirs = "//Users/kaku/Public/news/data/2006 Users/kaku/Public/news/data/2005 /Users/kaku/Public/news/data/2004 /Users/kaku/Public/news/data/2003";
#dirs = "ruby/tdiary/2005";
items = []

print "Content-type: text/html; charset=EUC-JP\n\n"
puts "<html><body>"

dirs.split(/ /).each {|dir|
        Dir::glob("#{dir}/*.td2").reverse_each {|f|
#      puts f
          File::open(f) {|fh|
            lines = fh.read
            lines.scan(amazon_url) {
#          puts $1
          items.push($1)
        }
          }
        }
}
items.uniq
count = 0
items.each {|i|
  count = count + 1
  print "<a href='http://www.amazon.co.jp/exec/obidos/ASIN/#{i}/kakuda-22/ref=nosim'><img src='http://images-jp.amazon.com/images/P/#{i}.09.MZZZZZZZ.jpg'></a>"
  #  if count % 5 == 0
  #    puts "<br>"
  #  else
    puts "&nbsp;"
  #  end
}
puts "</body></html>"
