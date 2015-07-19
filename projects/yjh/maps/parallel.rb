#!/usr/bin/env ruby

require 'open-uri'

urls = ["http://api.search.yahoo.co.jp/WebSearchService/V1/webSearch?appid=YahooDemo&query=yahoo",
        "http://api.search.yahoo.co.jp/ImageSearchService/V1/imageSearch?appid=YahooDemo&query=yahoo",
        "http://api.search.yahoo.co.jp/VideoSearchService/V1/videoSearch?appid=YahooDemo&query=yahoo",
        "http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=yahoo"
       ]

threads = []
contents = []
urls.each do |url|
  threads << Thread.new(url) do |u|
    contents << open(u).readlines
  end
end

threads.each { |thred| thred.join }

# p contents
