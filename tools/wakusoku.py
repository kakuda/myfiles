#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import re
import os
import logging
import time
from time import sleep
import sys

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s [%(levelname)s] %(message)s')


class WakusokuCrawler:

    def __init__(self, localdir):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.localdir = localdir
        self.initurl = 'http://blog.livedoor.jp/wakusoku/archives/396757.html'
        self.articleurl_regex = 'http://blog\.livedoor\.jp/wakusoku/archives/\d+\.html'
        self.imgurl_regex = 'http://livedoor\.blogimg\.jp/wakusoku/imgs/.*?'
        self.last_downloaded = int(time.time())
        self.error_count = 0

    def download(self, url):
        localpath = self.localdir + '/' + self.basename(url)
        if os.path.exists(localpath):
            self.logger.info(url + " is exists.")
            return
        if int(time.time()) - self.last_downloaded < 2:
            sleep(time.time() - self.last_downloaded)
        self.last_downloaded = int(time.time())
        content = self.get_content(url)
        if content == "":
            self.logger.info("Image is not found.")
            self.error_count = self.error_count + 1
        else:
            f = open(localpath, 'w')
            f.write(content)
            f.close()

    def get_content(self, url):
        if int(time.time()) - self.last_downloaded < 2:
            sleep(time.time() - self.last_downloaded)
        self.last_downloaded = int(time.time())
        self.logger.debug("get content: " + url)
        content = ""
        try:
            content = urllib2.urlopen(url).read()
        except urllib2.HTTPError, e:
            self.logger.warn("HTTP Error")
        except urllib2.URLError, e:
            self.logger.warn("Failed")
        return content

    # 記事から画像URL群を抽出
    def parse_article(self, articleurl):
        html = self.get_content(articleurl)
        if html == "":
            self.logger.info("Image urls are not found.")
            return ()
        imgurl_re = '<a href="(' + self.imgurl_regex + ')"(?: title=".*?")? target="_blank">'
        matches = re.compile(imgurl_re, re.M).findall(html)
        return matches

    # カテゴリURLから記事URL群を抽出
    def parse_category(self, categoryurl):
        html = self.get_content(categoryurl)
        if html == "":
            return ()
        url_re = '<a href="(' + self.articleurl_regex + ')" title=".*?" rel="bookmark">'
        matches = re.compile(url_re, re.M).findall(html)
        return matches

    def mkdir(self, path):
        if os.path.exists(path):
            return
        os.mkdir(path)

    def basename(self, url):
        return url.lstrip('http://livedoor.blogimg.jp/wakusoku/imgs/').replace('/', '_')

    def crawl(self):
        self.mkdir(self.localdir)
        matches = self.parse_category(self.initurl)
        for articleurl in matches:
            self.logger.info(articleurl)
            imgurls = self.parse_article(articleurl)
            for imgurl in imgurls:
                if self.error_count < 5:
                    self.download(imgurl)
                else:
                    self.logger.warn("Maybe, all images are lost: " + articleurl)
                    self.error_count = 0
                    break

    def scrape(self, url):
        self.mkdir(self.localdir)
        self.logger.info(url)
        imgurls = self.parse_article(url)
        for imgurl in imgurls:
            if self.error_count < 5:
                self.download(imgurl)
            else:
                self.logger.warn("Maybe, all images are lost: " + url)
                self.error_count = 0
                break

if __name__ == '__main__':
    c = WakusokuCrawler('/Volumes/HDD1/wakusoku/')
    if len(sys.argv) < 1 and sys.argv[1]:
        c.scrape(sys.argv[1])
    else:
        c.crawl()
