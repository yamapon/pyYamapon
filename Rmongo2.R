library(rmongodb)

mongo <- mongo.create(db = 'finance')

if (mongo.is.connected(mongo)){
  buf <- mongo.bson.buffer.create()
  
  #完全一致での検索方法
  mongo.bson.buffer.start.object(buf, "tse-t-ed:SecuritiesCode")
  mongo.bson.buffer.append(buf, "#text", "37120")
  mongo.bson.buffer.append(buf, "contextRef", "CurrentYearNonConsolidatedInstant")
  mongo.bson.buffer.finish.object(buf)
  
  #nestされた項目の部分検索方法(サンプル：業績修正データを取得)
  regex <- mongo.regex.create("tdnet-rvfc.*" , options="i")
  mongo.bson.buffer.append(buf, "link:schemaRef.xlink:href", regex)
  b <- mongo.bson.from.buffer(buf)
  
  #件数のカウント
  count <- mongo.count(mongo, 'finance.finance', query=b)
  print(count)
  
  #カーソルの取得
  cur <- mongo.find(mongo,'finance.finance', query=b)
    
  while( mongo.cursor.next(cur)){
    result <- mongo.cursor.value(cur)
    doc <- mongo.bson.value(result, "link:schemaRef")
    print(doc["xlink:href"])
    SecuritiesCode <- mongo.bson.value(result, "tse-t-ed:SecuritiesCode")
    ChangeNetSales <- mongo.bson.value(result, "tse-t-rv:ChangeNetSales")
    ChangeOperatingIncome <- mongo.bson.value(result, "tse-t-rv:ChangeOperatingIncome")
    ChangeOrdinaryIncome <- mongo.bson.value(result, "tse-t-rv:ChangeOrdinaryIncome")
    ChangeNetIncome <- mongo.bson.value(result, "tse-t-rv:ChangeNetIncome")
  
    #結果をファイルに出力
    #sink("C:/json.txt")
    #print(result) 
    #sink() 

    #dataframeに挿入する(NULLの場合を考慮する必要あり)
    df <- as.data.frame( list("SecuritiesCode" = SecuritiesCode["#text"], 
                              "ChangeNetSales" = ChangeNetSales["#text"], 
                              "ChangeOperatingIncome" = ChangeOperatingIncome["#text"], 
                              "ChangeOrdinaryIncome" = ChangeOrdinaryIncome["#text"], 
                              "ChangeNetIncome" = ChangeNetIncome["#text"]))
  }
  mongo.cursor.destroy(cur)
}