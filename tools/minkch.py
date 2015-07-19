#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import re
import os
import os.path
import logging
import time
from time import sleep
from urllib2 import HTTPError

class MinkchCrawler:

    def __init__(self, localdir):
        self.loglevel = logging.INFO
        self.localdir = localdir
        self.initurl = 'http://minkch.com/archives.html'
        self.articleurl_regex = 'http://minkch\.com/blog-\d+\.html'
        self.imgurl_regex = 'http://(?:img\.liyliu\.com|img\.plusei\.com)/.+?'
        self.last_downloaded = int(time.time())

    def download(self, url):
        localpath = self.localdir + '/' + self.basename(url)
        if os.path.exists(localpath):
            print url + " is exists."
            return
        if int(time.time()) - self.last_downloaded < 2:
            sleep(time.time() - self.last_downloaded)
        self.last_downloaded = int(time.time())
        print url
        try:
            content = urllib2.urlopen(url).read()
        except HTTPError, e:
            print url + " is HTTP Error"
            return
        f = open(localpath, 'w')
        f.write(content)
        f.close()

    def get_content(self, url):
        return urllib2.urlopen(url).read()

    # 記事から画像URL群を抽出
    def parse_article(self, articleurl):
        html = self.get_content(articleurl)
        imgurl_re = ' href="(' + self.imgurl_regex + ')" target="_blank">'
        matches = re.compile(imgurl_re, re.M).findall(html)
        return matches

    # カテゴリURLから記事URL群を抽出
    def parse_category(self, categoryurl):
        html = self.get_content(categoryurl)
        url_re = ' href="(' + self.articleurl_regex + ')" target="_self">'
        matches = re.compile(url_re, re.M).findall(html)
        return matches

    def mkdir(self, path):
        if os.path.exists(path):
            return
        os.mkdir(path)

    def basename(self, url):
        return os.path.basename(url)

    def run(self):
        self.mkdir(self.localdir)
        matches = self.parse_category(self.initurl)
        for articleurl in matches:
            print(articleurl)
            imgurls = self.parse_article(articleurl)
            for imgurl in imgurls:
                self.download(imgurl)

if __name__ == '__main__':
    c = MinkchCrawler('/Users/kaku/backup/Pictures/minkch.com')
    c.run()
