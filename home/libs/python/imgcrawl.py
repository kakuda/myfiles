# -*- coding: utf-8 -*-
"""Library for Image Crawl
"""
import urllib2
import cookielib
import gzip
import socket
import StringIO
import urllib
import re
import os
import logging
import time
from time import sleep
import sys

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s %(message)s')


class FirefoxClient(object):

    def __init__(self):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.last_accessed = int(time.time())
        cj = cookielib.CookieJar()
        cjhdr = urllib2.HTTPCookieProcessor(cj)
        self.opener = urllib2.build_opener(cjhdr)
        self.opener.addheaders =\
        [('User-agent', 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3'),
         ('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'),
         ('Accept-Language', 'ja,en-us;q=0.7,en;q=0.3'),
         ('Accept-Encoding', 'gzip,deflate'),
         ('Accept-Charset', 'Shift_JIS,utf-8;q=0.7,*;q=0.7'),
         ('Keep-Alive', '300'),
         ('Connection', 'keep-alive')]

    def request(self, url):
        self.realurl = url
        if int(time.time()) - self.last_accessed < 2:
            sleep(time.time() - self.last_accessed)
        self.last_accessed = int(time.time())
        res = self.opener.open(url)
        self.realurl = res.geturl()
        return self._extract_content(res)

    def get_realurl(self):
        return self.realurl

    def post(self, url, postdata):
        postdata = urllib.urlencode(postdata)
        res = self.opener.open(url, postdata)
        self.realurl = res.geturl()
        return self._extract_content(res)

    def _extract_content(self, res):
        if res.headers.has_key('Content-Length'):
            size = res.headers.get('Content-Length')
            self.logger.info('Size: ' + size)
        if res.headers.has_key('Content-Encoding') and \
           res.headers.has_key('Content-Type'):
            enc = res.headers.get('Content-Encoding')
            contype = res.headers.get('Content-Type')
            if enc.strip().lower() == 'gzip' and \
               contype.strip().lower().startswith('text/html'):
                sf = StringIO.StringIO(res.read())
                decoded = gzip.GzipFile(fileobj=sf)
                content = decoded.read()
        else:
            content = res.read()
        return content


class ImageCrawler(object):

    def __init__(self, localdir="."):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.set_savedir(localdir)
        self.client = FirefoxClient()

    def set_savedir(self, localdir):
        self.localdir = localdir

    def download(self, url):
        localpath = self.localdir + '/' + self.basename(url)
        if os.path.exists(localpath):
            self.logger.info(url + " is exists.")
            return
        self.logger.info(url)
        realurl, content = self.get_content_with_url(url)
        self.logger.info(realurl)
        self.logger.info(self.basename(realurl))
        localpath = self.localdir + '/' + self.basename(realurl)
        if os.path.exists(localpath):
            self.logger.info(self.basename(realurl) + " is exists.")
            return
        f = open(localpath, 'w')
        f.write(content)
        f.close()

    def get_content(self, url):
        return self.client.request(url)

    def get_content_with_url(self, url):
        content = self.client.request(url)
        realurl = self.client.get_realurl()
        return (realurl, content)

    def login(self, url, logindata):
        return self.client.post(url, logindata)

    def parse_page(self, pageurl, url_re):
        """ページを取得して指定した正規表現に
        マッチするものを返す(複数)
        マッチするものが無ければリトライする
        """
        html = self.get_content(pageurl)
        matches = re.compile(url_re, re.M).findall(html)
        if len(matches) < 1:
            self.logger.warning(pageurl + " is not match. try again.")
            matches = self.parse_page(pageurl, url_re)
        return matches

    def mkdir(self, path):
        if not os.path.exists(path):
            os.mkdir(path)

    def basename(self, url):
        base = os.path.basename(url)
        return urllib.unquote(base.split('?')[0]).replace('/', '-')
