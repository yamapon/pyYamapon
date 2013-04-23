library(rmongodb)

mongo <- mongo.create(db = 'finance')

buf <- mongo.bson.buffer.create()
value <- c( "37120", "CurrentYearNonConsolidatedInstant" )
names(value) <- c( "#text", "contextRef")
mongo.bson.buffer.append.string(buf, "tse-t-ed:SecuritiesCode", value)
b<-mongo.bson.from.buffer(buf)

#mongo.find.one(mongo,'finance.finance', b)
#以下で対象の抽出（select A from B where B.c = '11' )が出来た
#lst <- list("tse-t-rv:ForecastPreviousNetSales" = 1,
#            "tse-t-rv:ForecastPreviousOperatingIncome" = 1,
#            "tse-t-rv:ForecastPreviousOrdinaryIncome" = 1,
#            "tse-t-rv:ForecastPreviousNetIncome" = 1,
#            "tse-t-ed:ForecastOperatingIncome" = 1,
#            "tse-t-ed:ForecastOrdinaryIncome" = 1,
#            "tse-t-ed:ForecastNetIncome" = 1,
#            "tse-t-ed:NetSales" = 1,
#            "tse-t-ed:OperatingIncome" = 1,
#            "tse-t-ed:OrdinaryIncome" = 1,
#            "tse-t-edv:NetIncome" = 1)
#c <- mongo.bson.from.list(lst)
#cur <- mongo.find(mongo,'finance.finance', query=b,fields=c)

cur <- mongo.find(mongo,'finance.finance', query=b)

#項目の抽出
while( mongo.cursor.next(cur))
  result <- mongo.cursor.value(cur)
  print(result)
  ForecastPreviousNetSales <- mongo.bson.value(result, "tse-t-rv:ForecastPreviousNetSales")
  print(ForecastPreviousNetSales["#text"])

mongo.disconnect(mongo)