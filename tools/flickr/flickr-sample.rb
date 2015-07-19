# -*- coding: utf-8 -*-
require 'open-uri'
require 'rexml/document'
require 'cgi'
require 'rubygems'
require 'RMagick'
include Magick


def get_flickr_photos(letter)
  format = "rest"
  api_key = '0c862f893e602e0e6a6c20e03d6d506d'
  per_page = 30
  secret = '0893f11707651a0f'
  tagstr = 'one letter,' + letter
  if letter == '!'
    tagstr = 'punctuation,exclamationmark'
  end
  tags = CGI.escape(tagstr)
  tag_mode = 'all'

  url = "http://www.flickr.com/services/rest/?method=flickr.photos.search&format=#{format}&api_key=#{api_key}&per_page=#{per_page}&tags=#{tags}&tag_mode=#{tag_mode}"

  result = open(url)
  doc = REXML::Document.new(result)
  image_list = Array.new()
  doc.elements.each('rsp/photos/photo'){|ele|
    title  = ele.attributes["title"]
    farm   = ele.attributes["farm"]
    server = ele.attributes["server"]
    id     = ele.attributes["id"]
    secret = ele.attributes["secret"]
    # mstb
    # s=75x75
    # t=100x100
    # m=240x240
    # b=big
    # o=original
    mstb = "m"

    image_path = "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}_#{mstb}.jpg"
    image_list.push(image_path)
  }

  return image_list[rand(per_page)]
end

str = "HelloWorld!"
letters = str.split('')
letter_image_urls = []
letter_imglist = ImageList.new
letters.each do |c|
  url = get_flickr_photos(c)
  puts url
  letter_image_urls << url
  letter_imglist.read(url)
end


imglist = ImageList.new
tile = Rectangle.new(240, 240, 0, 0)
letter_imglist.scene = 0
num = 0
letter_image_urls.each do |url|
  imglist << letter_imglist[num]
  tile.x = num * 240
  imglist.page = tile
  num = num.next
end
mos = imglist.mosaic
mos.write('master_photo.jpg')
