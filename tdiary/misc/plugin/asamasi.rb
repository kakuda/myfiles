# asamasi.rb $Revision: 1.0 $
#
# asamasi: ���Ӥ����amazon-ad.js�˥��󥹥ѥ���
#   ��������Ҥ�������ɽ������.
#
#   @secure=true �Ǥ�ư��ޤ���
#
# Copyright (c) 2006 Naoyuki Kakuda <kakuda@gmail.com>
# Distributed under the GPL
def asamasi
  aid = "kakuda-22"
  f = open("/Users/kaku/Sites/tdiary/asamasi.txt")
  items = []
  f.each {|line|
    unless /^#/ =~ line
      item = line.split(/\s*\t\s*/)
      items.push(item)
    end
  }
  i = rand(items.size)
  result = "<a href=\"http://www.amazon.co.jp/exec/obidos/ASIN/#{items[i][0]}/#{aid}/ref=nosim\" target=\"_blank\" style=\"text-decoration: none;\"><img src=\"http://images-jp.amazon.com/images/P/#{items[i][0]}.09.MZZZZZZZ.jpg\" alt=\"#{items[i][1]}\"></a>\n"
  result
end
