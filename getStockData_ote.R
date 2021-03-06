#日々の個別銘柄（大証、JASDAQ）株価データ取得

dataList <- list.files("/Users/admin/Documents/stockdata_oj/")

targetDay <- as.Date(gsub("_ose.csv","",tail(dataList,1)))

while( targetDay < Sys.Date() ){
  
  #非営業日は除去
  #土曜日曜はskip、祝日はデータを読みこんで判定
  if(weekdays(targetDay)  != "土曜日"
     && weekdays(targetDay)  != "日曜日"){
    
    URL <- paste( "http://k-db.com/site/download.aspx?date=" , targetDay ,"&p=stockOJ&download=csv" ,sep ="")
    dfIndex <- read.csv(URL , header = FALSE ,fileEncoding = "cp932")
    
    if(format(targetDay) == dfIndex[1,1]){
      #data arengement
      dfIndex[1,1]<-NA
      dfIndex[2,1]<-NA
      dfIndex <- na.omit(dfIndex)
      dateData <- matrix( format(targetDay),  length(dfIndex$V1),1)
      dfIndex <- cbind( dateData , dfIndex)
      
      write.csv(dfIndex, file=paste("/Users/admin/Documents/stockdata_oj/", format(targetDay), "_ose.csv", sep=""),row.names=FALSE )
    }
  }
  targetDay <- targetDay + 1
  
}