# -*- coding: utf-8 -*-
require 'rubygems'
require 'RMagick'
include Magick
require 'xmlsimple'
require 'net/http'

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


def average_color(image)
  red, green, blue = 0, 0, 0
  image.each_pixel { |pixel, c, r|
    red += pixel.red
    green += pixel.green
    blue += pixel.blue
  }
  num_pixels = image.bounding_box.width * image.bounding_box.height
  return {:red => red/num_pixels, :green => green/num_pixels, :blue => blue/num_pixels}
end

def color_difference(rgb1, rgb2)
  red, green, blue = rgb1[:red] - rgb2[:red], rgb1[:green] - rgb2[:green], rgb1[:blue] - rgb2[:blue]
  Math.sqrt((red * red) + (green * green) + (blue * blue))
end

def match_photo(pixel, average_colors)
  ave = average_colors.collect { |color| color_difference(pixel, color) }
  ave.index(ave.min)
end


# 元画像を読み込んで、サイズを調整
width = 100
master = ImageList.new('master_photo.jpg')
master.resize_to_fit!(width,(master.bounding_box.height.to_f/master.bounding_box.width.to_f)*width)


# 元画像の各ピクセルのRGBを取得
pixel_array = []
master.each_pixel {|pixel, c, r|
  pixel_array << {:red => pixel.red, :green => pixel.green, :blue => pixel.blue}
}


# Yahoo! BOSS APIを使ってモザイク生成用画像を取得
photo_tiles = ImageList.new
population = 100
step_count = 50
#search_query = 'Leonardo Da Vinci'
search_query = 'flower'
boss_app_id = 'AAewDCjV34EDPCzy_dvBuBynYA0Oe0rlfUEWBrB9xm1vc8ijr4t5FaUp8QNjNbtrEylZ6kc-'
num = 1
(0..population).step(step_count) { |count|
  url = "http://boss.yahooapis.com/ysearch/images/v1/#{search_query}?appid=#{boss_app_id}&format=xml&count=#{step_count}&start=#{count}"
  puts url
  (res = Net::HTTP.get_response(URI.parse(URI.escape(url)))) rescue puts 'Cannot reach to URL'
  data = XmlSimple.xml_in(res.body, { 'ForceArray' => false })['resultset_images']['result']
#   data.each {|rec|
#     if rec['format'] == 'jpeg'
#       photo_tiles.read(rec['url']) rescue puts 'Cannot read image'
#       num = num.next
#     end
#   }
  data.parallelize(5) do |rec|
    if rec['format'] == 'jpeg'
      photo_tiles.read(rec['url']) rescue puts 'Cannot read image'
      num = num.next
      puts num
    end
  end
} rescue 'no more images found'

puts 'boss API end'

# 各モザイク用画像の平均色(RGB)を算出
average_colors = []
num = 1
photo_tiles.each { |img|
  average_colors << average_color(img)
  num = num.next
}

puts 'average_colors end'

tile_size = 40
mosaic_images = ImageList.new
tile = Rectangle.new(tile_size, tile_size, 0, 0)
photo_tiles.scene = 0
num = 0
master.bounding_box.height.times do |row|
  master.bounding_box.width.times do |col|
    idx = match_photo(pixel_array[num], average_colors)
    mosaic_images << photo_tiles[idx].crop_resized(tile_size, tile_size)
    tile.x = col * mosaic_images.columns
    tile.y = row * mosaic_images.rows
    mosaic_images.page = tile
    (photo_tiles.scene += 1) rescue photo_tiles.scene = 0
    num = num.next
  end
end

puts 'match_photos end'

mosaic = mosaic_images.mosaic
mosaic.write('mosaic.jpg')
