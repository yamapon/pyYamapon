library(rmongodb)

mongo <- mongo.create(db = 'finance')

buf <- mongo.bson.buffer.create()
mongo.bson.buffer.start.object(buf, "tse-t-ed:SecuritiesCode")
mongo.bson.buffer.append(buf, "#text", "37120")
mongo.bson.buffer.append(buf, "contextRef", "CurrentYearNonConsolidatedInstant")
#どうやらnestされた項目の部分探索はできない模様
#regex <- mongo.regex.create("CurrentYear.*ConsolidatedInstant", options="i")
#mongo.bson.buffer.append.regex(buf, "contextRef", regex)
mongo.bson.buffer.finish.object(buf)
b <- mongo.bson.from.buffer(buf)

print(mongo.find.one(mongo,'finance.finance', b))
