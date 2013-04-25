library(rmongodb)

mongo <- mongo.create(db = 'finance')

if (mongo.is.connected(mongo)){
  buf <- mongo.bson.buffer.create()
  
  #完全一致での検索方法
  #mongo.bson.buffer.start.object(buf, "tse-t-ed:SecuritiesCode")
  #mongo.bson.buffer.append(buf, "#text", "37120")
  #mongo.bson.buffer.append(buf, "contextRef", "CurrentYearNonConsolidatedInstant")
  #mongo.bson.buffer.finish.object(buf)
  
  #nestされた項目の部分検索方法(サンプル：業績修正データを取得)
  regex <- mongo.regex.create("tdnet-rvfc.*" , options="i")
  mongo.bson.buffer.append(buf, "link:schemaRef.xlink:href", regex)
  b <- mongo.bson.from.buffer(buf)
  
  #件数のカウント
  count <- mongo.count(mongo, 'finance.finance', query=b)
  print(count)
  
  #カーソルの取得
  cur <- mongo.find(mongo,'finance.finance', query=b)
    
  num <- 0
  while( mongo.cursor.next(cur)){
    result <- mongo.cursor.value(cur)
    doc <- mongo.bson.value(result, "link:schemaRef")
    SecuritiesCode <- mongo.bson.value(result, "tse-t-ed:SecuritiesCode")
    ChangeNetSales <- mongo.bson.value(result, "tse-t-rv:ChangeNetSales")
    ChangeOperatingIncome <- mongo.bson.value(result, "tse-t-rv:ChangeOperatingIncome")
    ChangeOrdinaryIncome <- mongo.bson.value(result, "tse-t-rv:ChangeOrdinaryIncome")
    ChangeNetIncome <- mongo.bson.value(result, "tse-t-rv:ChangeNetIncome")
  
    #dataframeに挿入する(NULLの場合を考慮する必要あり)
    if( is.null(ChangeNetSales) == FALSE 
        && is.null(ChangeOperatingIncome) == FALSE
        && is.null(ChangeOrdinaryIncome) == FALSE
        && is.null(ChangeNetIncome) == FALSE){
      
        df <- as.data.frame( list("SecuritiesCode" = SecuritiesCode, 
                                "ChangeNetSales" = ChangeNetSales, 
                                "ChangeOperatingIncome" = ChangeOperatingIncome, 
                                "ChangeOrdinaryIncome" = ChangeOrdinaryIncome, 
                                "ChangeNetIncome" = ChangeNetIncome))
              
    }else{
      #NG内容のものを
#      sink(paste("C:/", doc["xlink:href"], ".txt"))
#      print(result) 
#      sink() 
      
      num <- num + 1
    }
    
  }
  print(num)
  mongo.cursor.destroy(cur)
}