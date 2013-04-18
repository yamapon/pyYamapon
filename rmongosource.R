library(rmongodb)

mongo <- mongo.create(db = 'finance')

buf <- mongo.bson.buffer.create()
value <- c( "Prior1YearNonConsolidatedInstant", "DocumentInfo")
names(value) <- c( "#text", "contextRef")
mongo.bson.buffer.append.string(buf, "jpfr-di:ContextIDBeginningOfPeriodSCNonconsolidatedSS", value)
b<-mongo.bson.from.buffer(buf)

mongo.find.one(mongo,'finance.finance', b)
