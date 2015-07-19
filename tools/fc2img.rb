require 'open-uri'
require 'kconv'
require 'uri'

class String
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

def download(url)
  begin
    retry_count ||= 0
    image = open(url, 'rb').read
  rescue
    retry if retry_count < 3
  end
end

def saveimage(image, path)
  puts "#{path} exists." and return if FileTest.exists? path
  f = File.open(path, "w+b")
  f.puts image
  f.close
end

blog = ARGV.shift
dir = "/Users/kaku/backup/Pictures/".concat(URI.parse(blog).host)
dir.mkdir

html = open("#{blog}?all").read.toutf8
items = html.scan(/<a href="(.*?)"/i).flatten.uniq.select {|x| /blog\-entry.*?\.html/ =~ x}

items.each do |item|
  item = "#{blog}#{item}" unless item =~ /^http:/
  puts item
  entry = open(item).read.toutf8
  imgs = entry.scan(/href="(.*?)"/i).flatten.uniq.select {|x| /^http:.*\.jpg$/ =~ x}
  imgs.sort.uniq.each do |img|
    puts "download: #{img}"
    image = download(img)
    saveimage(image, "#{dir}/".concat(img.basename))
  end
end
