library(rmongodb)

mongo <- mongo.create(db = 'finance')

buf <- mongo.bson.buffer.create()
value <- c( "33440", "CurrentYearConsolidatedInstant")
names(value) <- c( "#text", "contextRef")
mongo.bson.buffer.append.string(buf, "tse-t-ed:SecuritiesCode", value)
b<-mongo.bson.from.buffer(buf)

#mongo.find(mongo,'finance.finance', b)
#以下で対象の抽出（select A from B where B.c = '11' )が出来た
lst <- list("tse-t-ed:ForecastOperatingIncome" = 1)
c <- mongo.bson.from.list(lst)
cur <- mongo.find(mongo,'finance.finance', query=b,fields=c)
while( mongo.cursor.next(cur))
  print(mongo.cursor.value(cur))