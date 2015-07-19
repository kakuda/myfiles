#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$KCODE='e'
require 'jcode'
require 'MeCab'
require 'tagcloud'
require 'uri'
require 'pstore'

def read_file(file)
  str = ""
  open(file) do |f|
    str = f.read
  end
  return str
end

def scan_items(str)
  item_regex = %r|\n\n　?(.*?)\n　?<a href="(.*?)" target="_blank">(.*?)</a>|im
  items = [] str.scan(item_regex) do
    items.push({"title" => $1, "url" => $2})
  end
  return items
end

def split_category(tdiary)
  regex = %r|Date: (\d+)\nTitle: 今日のニュース\nLast-Modified: \d+\nVisible: true\nFormat: tDiary\n\n<h2>技術ネタ</h2>(.*?)<h2>雑多ネタ</h2>(.*?)\n\n\.|im
  matches = []
  tdiary.scan(regex) do
    matches.push({"date" => $1, "tech" => $2, "zatta" => $3})
  end
  return matches
end

def split_tag(title)
  mecab = MeCab::Tagger.new
  nd = mecab.parseToNode(title)
  tag = []
  while  nd = nd.next
    if nd.feature.size > 1 && nd.feature != "BOS/EOS"
      optional = nd.feature.split(",")
      if nd.surface.size > 1 && optional[0] == "名詞" && (optional[1] == "固有名詞" || optional[1] == "一般")
        #        if optional[0] == "名詞"
        #         puts "#{nd.surface}(#{nd.surface.size}): #{optional.join(',')}"
        tag << "#{nd.surface}"
      end
    end
  end
  return tag
end

def tag_cloud_html(news, num)
  tags = {}
  news.each do |n|
    tgs = n["tag"]
    tgs.each do |t|
      if tags.key?(t)
        tags[t] = tags[t] + 1
      else
        tags[t] = 1
      end
    end
  end
  cloud = TagCloud.new
  tags.each_pair do |k, v|
    cloud.add(k, "http://www.google.com/custom?num=50&hl=ja&domains=secure.ddo.jp&sitesearch=secure.ddo.jp&q=#{URI.escape(k)}", v)
  end

  return cloud.html(num)
end

def domain_cloud_html(news, num)
  tags = {}
  news.each do |n|
    uri = URI.parse(n["url"])
    if tags.key?(uri.host)
      tags[uri.host] = tags[uri.host] + 1
    else
      tags[uri.host] = 1
    end
  end
  cloud = TagCloud.new
  tags.each_pair do |k, v|
    cloud.add(k, "http://#{k}/", v)
  end
  return cloud.html(num)
end

def store_news_by_tag(news, month)
  db = PStore.new("db/tag#{month}.db")
  db.transaction do
    news.each do |n|
      tags = n['tag']
      tags.each do |tag|
        if db.root?(tag)
          db[tag] << {"date" => n["date"], "url" => n["url"], "title" => n["title"] }
        else
          db[tag] = [{"date" => n["date"], "url" => n["url"], "title" => n["title"] }]
        end
      end
    end
  end
end

def store_news_by_domain(news, month)
  db = PStore.new("db/domain#{month}.db")
  db.transaction do
    news.each do |n|
      uri = URI.parse(n["url"])
      if db.root?(uri.host)
        db[uri.host] << {"date" => n["date"], "url" => n["url"], "title" => n["title"] }
      else
        db[uri.host] = [{"date" => n["date"], "url" => n["url"], "title" => n["title"] }]
      end
    end
  end
end

def get_news(key, dbname)
  db = PStore.new("db/#{dbname}.db")
  news = []
  db.transaction(true) do
    if db.root?(key)
      news = db[key]
    end
  end
  return news
end

def generate_html(news, month)
  f = File.open("html/#{month}.html",'w')
  f.puts read_file("html/header.html")
  f.puts "<div id=\"links\">"
  f.puts tag_cloud_html(news, 100)
  f.puts "</div>"
  f.puts "<div id=\"links\">"
  f.puts "<br/>" * 2
  f.puts domain_cloud_html(news, 100)
  f.puts "</div>"
  f.puts read_file("html/footer.html")
  f.close
end

## main

#td2 = "/Users/kaku/Public/news/data/2006/200601.td2"
root_dir = "td2"

td2_files = Dir::glob("#{root_dir}/*.td2")
td2_files.each do |td2|
  month = File.basename(td2, ".td2")
  tdiary = read_file(td2)

  news = []
  cates = split_category(tdiary)
  cates.each do |dailynews|
    techs = scan_items(dailynews["tech"])
    techs.each do |i|
      tag = split_tag(i["title"])
      news << {"date" => dailynews["date"], "category" => "tech", "title" => i["title"], "url" => i["url"], "tag" => tag}
    end
    zattas = scan_items(dailynews["zatta"])
    zattas.each do |i|
      tag = split_tag(i["title"])
      news << {"date" => dailynews["date"], "category" => "zatta", "title" => i["title"], "url" => i["url"], "tag" => tag}
    end
  end
  store_news_by_tag(news, month)
  store_news_by_domain(news, month)

  generate_html(news, month)

  p get_news("Java", "tag#{month}").size
  p get_news("d.hatena.ne.jp", "domain#{month}")
end

