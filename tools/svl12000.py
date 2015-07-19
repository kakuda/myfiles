#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import urllib2
import re
import time


def main():
    svl_url = 'http://www.alc.co.jp/goi/svl_l05_list.htm'
    html = urllib2.urlopen(svl_url).read()
    regex = '^ +([a-z]+) (?:<br>|</font> </td>)$'
    matches = re.compile(regex, re.M|re.I).findall(html)
    for word in matches:
        u = "http://ajax.googleapis.com/ajax/services/language/translate?v=1.1&q=%s&langpair=en|ja" % word
#         print u
        time.sleep(2)
        j = json.load(urllib2.urlopen(u))
        print word + "\t" + j['responseData']['translatedText'].encode('utf-8')

if __name__ == '__main__':
    main()
