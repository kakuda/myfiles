$KCODE = 'u'
require 'jcode'

class JapaneseExtractor
  def initialize
  end

  def extract_addr(str)
    return str.scan(/([一-龠]+[都|道|府|県|][一-龠]+[市|区|町|村|])/u)
  end
  
  def is_zenkaku_katakana(str)
    (?:\xE3\x81[\x81-\xBF]|\xE3\x82[\x80-\x93])
  end

  def extract_person_name(str)
    return str.scan(/[、|の](.*?)[が|（|は]/u).flatten
    # return str.scan(/[、|・|の](.*?)[が|は|（]/u).flatten.select {|x| x.split(//u).length < 8 }
  end
end
jp = JapaneseExtractor.new

sentense = '「仮面ライダーシリーズに出演したい」と芸能界デビューしたＧカップの爆乳ボディーのグラビアアイドル、大空かのん（２０）が２５日にファーストＤＶＤ「発掘美少女０９」（グラッツコーポレーション、３９９０円）を発売ＰＲのため、東京・大手町のＺＡＫＺＡＫ編集部に来社した。'
puts jp.extract_person_name(sentense)

sentense = 'リンパ腫のため３月下旬に入院、治療に専念してきた元花組トップの愛華みれ（４３）は前日の１４日から「シンデレラ　ｔｈｅ　ミュージカル」の稽古に復帰した。'
p jp.extract_person_name(sentense)

sentense = '愛知県岡崎市の東名高速道路で１６日午後に発生したバスジャック事件。'
puts jp.extract_addr(sentense)
sentense = '歌手の浜崎あゆみが女性下着メーカー・ワコール社のアジア向け新広告で、初の下着姿を披露していることが16日（水）明らかになった。'
puts jp.extract_person_name(sentense)

sentense = '情報サイト『ZAKZAK』主催による『第1回 日本グラビアアイドル大賞』をタレントの小倉優子が受賞し16日（水）、東京・大手町の同編集部で行われた表彰式に出席した。'
puts jp.extract_person_name(sentense)
sentense = '他にはハンドボール日本代表の宮崎大輔（２７）やタレント・にしおかすみこ（３３）らが参加する。'
puts jp.extract_person_name(sentense)
sentense = '「仮面ライダーシリーズに出演したい」と芸能界デビューしたＧカップの爆乳ボディーのグラビアアイドル、大空かのん（２０）が２５日にファーストＤＶＤ「発掘美少女０９」（グラッツコーポレーション、３９９０円）を発売ＰＲのため、東京・大手町のＺＡＫＺＡＫ編集部に来社した。'
puts jp.extract_person_name(sentense)
