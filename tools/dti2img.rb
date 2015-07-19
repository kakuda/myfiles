require 'rubygems'
require 'scrapi'
require 'open-uri'
require 'kconv'
require 'uri'

class String
  def scrape(pattern, options = {}, &block)
    options = {:extract=>options} unless options.is_a?(Hash)
    options[:parser_options] = {:char_encoding=>'utf8'}.merge(options[:parser_options]||{})
    extract = options.delete(:extract) || block && :element || :text
    scraped = Scraper.define do
      process pattern, "matches[]"=>extract
      result :matches
    end.scrape(self, options) || []
    block ? scraped.map{|i| block.call(i)} : scraped
  end

  def mkdir
    return if FileTest.directory?(self)
    Dir::mkdir(self)
  end

  def basename
    fname = ""
    if self =~ %r!.*/(.*)$!i
      fname = $1;
    end
    return fname
  end
end


class HTML::Tag
  def text() Scraper::Base.text(self) end
end

def saveimage(image, path)
  f = File.open(path, "w+b")
  f.puts image
  f.close
end

blog = "http://doragong.19.dtiblog.com/"
dir = "/Users/kaku/Pictures/".concat(URI.parse(blog).host)
dir.mkdir

html = open(blog).read.toutf8
#puts html
# 月別記事一覧を取得
items = html.scrape("div#menu-body > ul.list > li a", "@href").select {|x| /^blog-date-.*?/ =~ x}

items.each do |item|
  puts "#{blog}#{item}"
  entry = open("#{blog}#{item}").read.toutf8
  # 記事中のリンク一覧を取得
  imgs = entry.scrape("div.entry-body a", "@href").select {|x| /.*\.jpg$/ =~ x}
  imgs.sort.uniq.each do |img|
    puts "download: #{img}"
    image = open(img, 'rb').read
    saveimage(image, "#{dir}/".concat(img.basename))
  end
end

#puts links
#end

