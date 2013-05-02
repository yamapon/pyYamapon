library("RSQLite")

drv <- dbDriver("SQLite", max.con = 1)
conn <- dbConnect(drv, dbname="indexdata") 

#rs <- dbSendQuery( conn, 
#    "CREATE TABLE indexData ( 
#     date DATE, 
#     code TEXT, 
#     open INTEGER,
#     high INTEGER,
#     low INTEGER,
#     close INTEGER,
#     primary key(date, code)
#      );" 
#)
targetDay <- Sys.Date() -2
while( targetDay > "2013-04-25"){
  URL <- paste( "http://k-db.com/site/download.aspx?date=" , targetDay ,"&p=index&download=csv" ,sep ="")
  dfIndex <- read.csv(URL , header = FALSE )

  dfIndex[1,1]<-NA
  dfIndex[2,1]<-NA
  dfIndex <- na.omit(dfIndex)

  # Data Insert
  dbBeginTransaction(conn)
  dbGetPreparedQuery(conn, "INSERT INTO indexData VALUES( targetDay , :V1 , :V2 ,:V3, :V4, :V5)", bind.data=dfIndex)
  dbCommit(conn)
  
  targetDay <- targetDay - 1

}
# select statements
#rs <- dbSendQuery( conn, "SELECT * FROM indexData;" )
#t <- fetch(rs, n = -1)

dbDisconnect(conn)