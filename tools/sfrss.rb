#!/usr/bin/env ruby
require 'open-uri'

host = "http://sourceforge.net"
baseurl = host + "/mailarchive/forum.php?forum="
forum = "vraptor2-devel"
forumurl = baseurl + forum

def get_content(url)
  content = ""
  open(url) do |f|
    content = f.read
  end
  return content
end

def content_scan(content, regex)
  matches = []
  content.scan(regex) { matches.push($1) }
  return matches.uniq
end

def make_rss(title, link, threads)
  resources = ""
  items = ""
  threads.each do |t|
    resources << "<rdf:li rdf:resource=\"#{t['url']}\" />\n"
    items << <<RSS_ITEM
<item rdf:about="#{t['url']}">
  <link>#{t['url']}</link>
  <dc:date>#{t['last']}</dc:date>
  <title>#{t['topic']}(#{t['posts']})</title>
  <dc:creator>#{t['starter']}</dc:creator>
  <description>#{t['message']}</description>
</item>
RSS_ITEM
  end

  return <<RSS
<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="ja-JP">
 <channel rdf:about="http://dev02.map.miniy.yahoo.co.jp/">
  <title>#{title}</title>
  <link>#{link}</link>
  <description />
  <dc:creator>SourceForge.net</dc:creator>
  <items>
 <rdf:Seq>
 #{resources}
  </rdf:Seq>
  </items>
 </channel>
 #{items}
</rdf:RDF>
RSS

end

c = get_content(forumurl)
regex = %r|<td width="50%"><a href="(.*?)"><img src="http://images\.sourceforge\.net/images/ic/cfolder15\.png" alt="" width="15" height="13" /> &nbsp; <!-- google_ad_section_start -->(.*?)<!-- google_ad_section_end --></a></td>\n\t+<td>(.*?)</td>\n\t+<td>(\d+)</td>\n\t+<td>(.*?)</td>|im

threads = []
c.scan(regex) {
  threads.push( {"url" => $1, "topic" => $2, "starter" => $3, "posts" => $4, "last" => $5})
}
#puts threads.length 
#p threads

threads.each do |t|
  c = get_content(host + t["url"])
  reg = %r|<!-- google_ad_section_start --><pre>(.*?)</pre><!-- google_ad_section_end -->|im
  messages = content_scan(c, reg)
  t["message"] = messages[-1]
end

rss = make_rss("SourceForge.net: " + forum, forumurl, threads)
puts rss
