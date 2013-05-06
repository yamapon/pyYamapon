#日々の個別銘柄（東証）株価データ取得

targetDay <- Sys.Date()
while( targetDay >= "2008-01-01"){
  
  #非営業日は除去
  #土曜日曜はskip、祝日はデータを読みこんで判定
  if(weekdays(targetDay)  != "土曜日"
     && weekdays(targetDay)  != "日曜日"){
    
    URL <- paste( "http://k-db.com/site/download.aspx?date=" , targetDay ,"&p=stockT&download=csv" ,sep ="")
    
    dfIndex <- read.csv(URL , header = FALSE ,fileEncoding = "cp932")
    
    if(format(targetDay) == dfIndex[1,1]){
      #data arengement
      dfIndex[1,1]<-NA
      dfIndex[2,1]<-NA
      dfIndex <- na.omit(dfIndex)
      dateData <- matrix( format(targetDay),  length(dfIndex$V1),1)
      dfIndex <- cbind( dateData , dfIndex)
      
      write.csv(dfIndex, file=paste("/Users/admin/Documents/stockdata_t/", format(targetDay), "_tse.csv", sep=""),row.names=FALSE )
    }
  }
  targetDay <- targetDay - 1
  
}