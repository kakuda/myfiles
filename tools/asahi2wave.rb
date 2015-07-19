require 'rubygems'
require 'scrapi'
require 'open-uri'
require 'kconv'
require 'osx/cocoa'
require 'uri'

synth = OSX::NSSpeechSynthesizer.alloc.init
#synth.startSpeakingString "Hello, world"

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
end

class HTML::Tag
  def text() Scraper::Base.text(self) end
end

html = open("http://www.asahi.com/").read.toutf8
items = html.scrape("ul.list > li a:nth-child(1)") {|e|
  { :title => e.text, :url => e["href"] }
}
#puts items
#items.each do |item|
item = items[0]
  unless item[:url] =~ /^http:/
    item[:url] = "http://www.asahi.com".concat(item[:url])
  end
  puts item[:url]

  xml = open(URI.escape("http://www.kawa.net/works/ajax/romanize/romanize.cgi?mode=japanese&ie=utf-8&q=#{item[:title]}")).read
  word = xml.scan(/<span title="(.*?)">.*?<\/span>/).flatten.join("")
  puts word
  synth.startSpeakingString word
#end

#html = open("http://www.asahi.com/national/update/1023/NGY200710230017.html").read.toutf8
#puts html.scrape("div.kiji"){|e| [e.text.gsub(/\n/, '').toeuc]}
