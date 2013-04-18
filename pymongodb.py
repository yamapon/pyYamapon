#!/usr/bin/env python
# -*- coding:utf-8 -*-

from pymongo import Connection

import json

#コネクション作成
con = Connection('localhost', 27017)
#コネクションからtestデータベースを取得
db = con.finance
#testデータベースからfooコレクションを取得
col = db.finance

"""
f = open('c:\\tdnet-rvfc-99630-20130408013680.json') 
data1 = f.read()  # ファイル終端まで全て読んだデータを返す 
value = json.loads(data1)
db.finance.insert(value)
f.close() 
"""
doc = db.finance.find_one()
#data = json.dumps(doc)
print doc

con.disconnect()
