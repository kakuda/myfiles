#!/usr/bin/env ruby

require 'open-uri'
require 'rexml/document'
include REXML

f = open("http://api.map.yahoo.co.jp/LocalSearchService?/V1/LocalSearch??appid=YahooDemo&p=%E5%85%AD%E6%9C%AC%E6%9C%A8%E3%83%92%E3%83%AB%E3%82%BA")
doc = Document.new(f)
doc.elements.each('/LocalSearchResult?/Item') do |item|
  puts item.elements['Title'].text
end
