#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import re
import os.path
import logging
from time import sleep

class ImpromptuChmGenerator:
    def __init__(self, localdir):
        self.loglevel = logging.INFO
        self.localdir = localdir

    def download(self, url):
        localpath = self.localdir + '/' + os.path.basename(url)
        if os.path.exists(localpath):
            logging.info(url + " is exists.")
            return
        html = urllib2.urlopen(url).read()
        f = open(localpath, 'w')
        f.write(html)
        f.close()


logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s')

def download(url, localdir):
    html = urllib2.urlopen(url).read()
    f = open(localdir + "/" + os.path.basename(url), "w")
    f.write(html)
    f.close()


def get_func_index():
    if os.path.exists("/Users/kaku/work/func_index.html") == False:
        url = "http://impromptu.moso.com.au/func_index.html"
        index_html = urllib2.urlopen(url).read()
        f = open("/Users/kaku/work/func_index.html", "w")
        f.write(index_html)
        f.close()
    f2 = open("/Users/kaku/work/func_index.html", "r")
    return f2.read()


def compile_template(matches):
    template_header = """
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">

</HEAD><BODY>
<UL>"""
    template_footer = """
</UL>
</BODY></HTML>"""
    res = template_header
    for match in matches:
        res += generate_item(match)
    res += template_footer
    return res

def generate_item(match):
    url = match[0].replace('/', '\\', 1).replace('%', '%0025').replace(':', '%003A').replace('*', '%002A')

    return """
  <LI><OBJECT type="text/sitemap">
    <param name="Name" value="%s">
    <param name="Local" value="%s">
    </OBJECT>""" % (match[1], url)

def generate_project(matches):
    res = """
[OPTIONS]
Compatibility=1.0
Compiled file=impromptu.chm
Contents file=impromptu.hhc
Default Window=Main
Default topic=func_index.html
Display compile progress=Yes
Enhanced decompilation=Yes
Full-text search=Yes
Language=0x809 English
Title=Impromptu 1.3 Function Index

[INFOTYPES]


[FILES]
"""
    for match in matches:
        res += match[0].replace('/', '\\').replace('%', '%0025').replace(':', '%003A').replace('*', '%002A') + "\n"
    return res

if __name__ == '__main__':
    func_index = get_func_index()

    re_title = '<h2>\n\t+(.*?)\n\t+</h2>'
    re_link = '\s*<a href="(functions\/.*?\.html)">(.*?)</a><br\/?>\s*\n*'
    # re_all = '(' + re_title + '</a>\n(' + re_link + ')+)+'
    re_all = re_link

    matches = re.compile(re_all, re.M).findall(func_index)
    if matches == None:
        logging.warn("No Match!")
        exit

    logging.debug(len(matches))
    for match in matches:
        logging.debug(generate_item(match))
        url = 'http://impromptu.moso.com.au/' + match[0]
        if url == 'http://impromptu.moso.com.au/functions/math:vector%.html':
            url = 'http://impromptu.moso.com.au/functions/math:vector%25.html'
        logging.info(url)
        if os.path.exists("/Users/kaku/work/functions/" + os.path.basename(url)):
            logging.info(url + " is exists.")
        else:
            download(url, '/Users/kaku/work/functions')
            sleep(2.0)

    index_file = open('impromptu.hhc', 'w')
    index_file.write(compile_template(matches))
    index_file.close()

    index_file = open('impromptu.hhp', 'w')
    index_file.write(generate_project(matches))
    index_file.close()
