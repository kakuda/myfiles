#!/usr/bin/env ruby

require 'open-uri'

def get_content(url)
  content = ""
  open(url) do |f|
    content = f.read
  end
  return content
end

def download(url, path)
  open(path, 'w') do |f|
    f.puts get_content(url)
  end
end

def extract_filename(url)
  return url.split(/\s*\/\s*/)[-1]
end

def scan_elisp_url(path)
  c = get_content(path)
  return c.scan(%r!http://\S+\.el!)
end

dotemacs = '~/.emacs'
emacsd = '~/.emacs.d'

urls = scan_elisp_url(File.expand_path(dotemacs))
urls.each do |url|
  puts url
  name = extract_filename(url)
  download(url, File.expand_path(emacsd) + '/' + name)
end
