require 'open-uri'
require 'uri'
require 'cgi'

module Enumerable
  def parallelize(max_thread_count = nil)
    raise ArgumentError, 'block not given' unless block_given?
    thread_count = 0
    main_thread = Thread.current
    each do |a|
      Thread.start(a) do |a|
        begin
          yield(a)
        ensure
          Thread.critical = true
          thread_count -= 1
          main_thread.wakeup
          Thread.critical = false
        end
      end
      Thread.critical = true
      thread_count += 1
      Thread.stop if max_thread_count && thread_count >= max_thread_count
      Thread.critical = false
    end
    loop do
      begin
        Thread.critical = true
        break if thread_count == 0
        Thread.stop
      ensure
        Thread.critical = false
      end
    end
    nil
  end
end

def download(url)
  begin
    retry_count ||= 0
    puts "download: #{url}"
    open(url, 'rb') { |f| f.read }
  rescue
    "Oops... something to error: " + url
    retry if retry_count < 3
  end
end

def rename_ext(filename, ext)
  filename.gsub(/\.\w+$/, ext)
end

def save_flv(flv, path)
  puts "#{path} exists." and return if FileTest.exists? path
  f = File.open(path, "w+b")
  f.puts flv
  f.close
end

def extract_flvs(html)
  html.scan(/href="(http:\/\/www\.yourfilehost\.com\/media\.php.*?)"/).flatten
end

SAVE_DIR = "/Users/kaku/backup/Movies/"

def download_flv(url)
  url = CGI.unescapeHTML(url.strip)
  # puts "hoge: " + url
  fname = url.scan(/^.*?&file=(.*?)$/).flatten[0]
  name = rename_ext(fname, '.flv')

  html = open(url) { |f| f.read }
  swf_url = html.scan(/<param name="movie" value="(.*?)" \/>/).flatten[0]
  # puts "swf_url: " + swf_url
  flv_url = swf_url.scan(/^.*?&videoembed_id=(.*?)$/).flatten[0]
  save_path = SAVE_DIR + name
  if FileTest.exists? save_path
    puts "#{save_path} is already exits."
  else
    flv = download(URI.unescape(flv_url))
    save_flv(flv, save_path)
  end
end

def main
  url = ARGV.shift
  if ! url
    puts "specify url"
    return
  elsif url =~ /^http:\/\/www\.yourfilehost\.com\/media\.php/
    download_flv(url)
  else
    html = open(url) { |f| f.read }
    flvs = extract_flvs(html)
    # flvs.each do |flv|
    flvs.parallelize(3) do |flv|
      download_flv(flv)
    end
  end
end

main
