#!/usr/local/bin/ruby
#!/usr/bin/env ruby
require "cgi"
require "iconv"

regex = /\n([^\n]+)\n<a href="(\S+)"/
dirs = "/Users/kaku/Public/news/data/2005 /Users/kaku/Public/news/data/2004 /Users/kaku/Public/news/data/2003";

class Item
  def initialize(title, url)
    @title = title
    @url = url
  end
  def title
    @title
  end
  def url
    @url
  end
  def to_s
    "#{@title}\n#{@url}"
  end
  def ismatch(str)
    keywords = str.split(/ /)
    count = 0
    keywords.uniq.each {|keyword|
      if @title =~ keyword or @url =~ keyword
        count = count + 1
      end
    }
    count == keywords.size
  end
end

cgi = CGI.new
#foo = File.open("ruby/tdiary/foo.txt",'w')
#foo.puts "Content-type: text/plain\n\n"
print "Content-type: text/html; charset=EUC-JP\n\n"
if cgi.params['q'][0] == ''
  exit
end
encq = Iconv.iconv("EUC-JP", "UTF-8", cgi['q'])
print encq
#exit
#Dir::glob("ruby/tdiary/2005/*.td2").each {|f|
dirs.split(/ /).each {|dir|
  Dir::glob("#{dir}/*.td2").reverse_each {|f|
#      puts "<dl>#{f}</dl>"
    items = []
    File::open(f) {|fh|
      lines = fh.read
      lines.scan(regex) { items.push(Item.new($1, $2)) }
    }
    items.uniq.each {|item|
#      if item.ismatch(Kconv::toeuc(cgi['q'][0]))
      if item.ismatch(encq)
#        foo.puts "<li><a href=\"#{item.url}\" target=\"_blank\">#{item.title}</a></li>"
        puts "<li><a href=\"#{item.url}\" target=\"_blank\">#{item.title}</a></li>"
      end
    }
  }
}
