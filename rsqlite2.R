library("RSQLite")

drv <- dbDriver("SQLite", max.con = 1)
conn <- dbConnect(drv, dbname="indexdata") 

#rs <- dbSendQuery( conn, 
#    "CREATE TABLE indexData ( 
#     date TEXT, 
#     code TEXT, 
#     open NUMERIC,
#     high NUMERIC,
#     low NUMERIC,
#     close NUMERIC,
#     primary key(date, code)
#      );" 
#)
targetDay <- Sys.Date() -3
while( targetDay > "2013-04-25"){
  
  #非営業日は除去
  #土曜日曜はskip、祝日はデータを読みこんで判定
  URL <- paste( "http://k-db.com/site/download.aspx?date=" , targetDay ,"&p=index&download=csv" ,sep ="")
  dfIndex <- read.csv(URL , header = FALSE ,fileEncoding = "cp932", skip = 2)
  
  #row delete
  #dfIndex[1,1]<-NA
  #dfIndex[2,1]<-NA
  #dfIndex <- na.omit(dfIndex)
  
  #data arengement
  dateData <- matrix( format(targetDay),  length(dfIndex$V1),1)
  dfIndex <- cbind( dateData , dfIndex)
  
  # Data Insert
  dbBeginTransaction(conn)
  dbGetPreparedQuery(conn, "INSERT INTO indexData VALUES( :dateData , :V1 , :V2 ,:V3, :V4, :V5)", bind.data=dfIndex)
  dbCommit(conn)
  
  targetDay <- targetDay - 1
  
}
# select statements
#rs <- dbSendQuery( conn, "SELECT * FROM indexData;" )
#t <- fetch(rs, n = -1)

dbDisconnect(conn)