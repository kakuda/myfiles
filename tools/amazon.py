#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib
import urllib2
import hmac
import hashlib
import base64
from datetime import datetime


class ProductAdvertising:

    def __init__(self, access_key_id, secret_key,
                 associate_tag=None, version='2008-08-19'):
        self.access_key_id = access_key_id
        self.secret_key = secret_key
        self.associate_tag = associate_tag
        self.version = version
        self.uri = 'webservices.amazon.co.jp'
        self.end_point = '/onca/xml'

    def item_lookup(self, asin, options={}):
        options['Operation'] = 'ItemLookup'
        options['ItemId'] = asin
        return self.send_request(options)

    def wish_lookup(self, listid, options={}):
        options['Operation'] = 'ListLookup'
        options['ListType'] = 'WishList'
        options['ListId'] = listid
        options['ResponseGroup'] = 'ItemAttributes'
        options['Condition'] = 'All'
        options['ProductPage'] = 1
        return self.send_request(options)

    def send_request(self, options):
        options['Service'] = 'AWSECommerceService'
        options['AWSAccessKeyId'] = self.access_key_id
        options['Version'] = self.version

        # Timestampをセットしないとエラーになる。
        # タイムスタンプはGMT(≒UTC)
        options['Timestamp'] = datetime.utcnow().isoformat()

        if self.associate_tag:
            options['AssociateTag'] = self.associate_tag

        # パラメーターをソートしてURLエンコード
        payload = ""
        for v in sorted(options.items()):
            payload += '&%s=%s' % (v[0], urllib.quote(str(v[1])))
        payload = payload[1:]

        # 署名用の文字列
        strings = ['GET', self.uri, self.end_point, payload]

        # 署名の作成
        digest = hmac.new(self.secret_key,
                          '\n'.join(strings),
                          hashlib.sha256).digest()
        signature = base64.b64encode(digest)

        url = "http://%s%s?%s&Signature=%s" % \
        (self.uri, self.end_point, payload, urllib.quote_plus(signature))
        return urllib2.urlopen(url).read()

if __name__ == '__main__':
    pa = ProductAdvertising(access_key_id='06PH3JZHQDX54R98YDR2',
                            secret_key='arFMkCnHTs2c3MYZMqNNzeVq/dBDD2oeBz2Y3JjD')
    print pa.wish_lookup('28Q7AZMCK51QZ')
