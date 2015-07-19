#!/usr/bin/env python
# -*- coding: utf-8 -*-
from imgcrawl import ImageCrawler
"""
    surl = 'http://moe.imouto.org/pool/show/1034'
    zip_re = 'href="(/pool/zip/.*?\?samples=1)"'
    zips = c.parse_page(surl, zip_re)
    for zpath in zips:
        zurl = 'http://moe.imouto.org' + zpath
        c.download(zurl)
"""
if __name__ == '__main__':
    authurl = 'http://moe.imouto.org/user/authenticate'
    logindata = {'user[name]': 'dspckt',
                 'user[password]': 'edp1601'}
#     c = ImageCrawler()
    c = ImageCrawler('/Users/kaku/Downloads/moeimo')
    c.login(authurl, logindata)

    print 'Logined!'

    rooturl = 'http://moe.imouto.org/pool'
    showpool_re = 'href="/pool/show/(\d+)">(.*?)</a>'
    zip_re = 'href="(/pool/zip/.*?\?samples=1)".*?>LQ \(([\d\.]+) (?:Bytes|KB|MB)\)</a>'
    nums = c.parse_page(rooturl, 'href="/pool\?page=(\d+)"')
    maxpage = max(map(int, nums))
    for i in range(1, maxpage + 1):
        url = 'http://moe.imouto.org/pool?page=%d' % i
        shows = c.parse_page(url, showpool_re)
        for pool in shows:
            pid, title = pool
            surl = 'http://moe.imouto.org/pool/show/%s' % pid
            zips = c.parse_page(surl, zip_re)
            for z in zips:
                zpath, size = z
                zurl = 'http://moe.imouto.org' + zpath
                if float(size) == 0:
                    print "%s is 0 byte." % zurl
                else:
                    c.download(zurl)
