#!usr/bin/env python
# -*- coding: utf-8 -*-

'''
1 これはペンです
2 最近はどうですか？
3 ペンギン大好き
4 こんにちは。いかがおすごしですか？
5 ここ最近疲れ気味
6 ペンキ塗りたてで気味が悪いです
'''

import sys, codecs

sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
index = {}
num_docs = 0

for line in sys.stdin:
    doc = line.decode('utf-8').strip().split(' ', 1)
    if len(doc) != 2: continue
    id, text = doc
    bigrams = []
    for i in xrange(len(text) - 1):
        bigram = ''.join((text[i], text[i + 1]))
        if bigram in bigrams: continue
        if bigram in index:
            index[bigram].append(id)
        else:
            index[bigram] = [id]
            bigrams.append(bigram)
    num_docs += 1

print "#NUM=%s" % num_docs
keys = index.keys()
keys.sort()
for key in keys:
    print "%s %s" % (key, ','.join(index[key]))
