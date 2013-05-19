library("RSQLite")

drv <- dbDriver("SQLite", max.con = 1)
conn <- dbConnect(drv, dbname="db.stockdata") 

#Insert開始日時を登録
sDate <- as.character.Date(Sys.Date())
sDate <- edit(sDate)
targetDay <- as.Date(sDate)

#Insert
dbBeginTransaction(conn)
while( targetDay < Sys.Date()){
  
  #指数データ
  indexData <- NULL
  fileName <- paste("/Users/admin/Documents/indexdata/", format(targetDay), "_index.csv", sep="")  
  tryCatch({ 
    indexData <- read.csv(fileName , header = FALSE , skip = 1, colClasses = "character",fileEncoding = "utf-8" )
    indexData$V2 <- gsub("東証業種別_", "", indexData$V2)
    dbGetPreparedQuery(conn, "INSERT INTO stockIndex VALUES( :V1 , :V2 ,:V3, :V4 ,:V5,:V6)", bind.data=indexData)
  },  
  error = function(e) {
  })  
  
  #東証データ
  tseStcokData <- NULL  
  fileName <- paste("/Users/admin/Documents/stockdata_t/", format(targetDay), "_tse.csv", sep="")
  
  tryCatch({ 
    tseStockData <- read.csv(fileName , header = FALSE , skip = 1, colClasses = "character",fileEncoding = "utf-8" )
    dbGetPreparedQuery(conn, "INSERT INTO stockData VALUES( :V1 , :V2 ,:V3, :V4, :V5, :V6 , :V7 ,:V8, :V9, :V10, :V11)", bind.data=tseStockData)
  },  
  error = function(e) {
  })
  
  #大証データ
  oseStcokData <- NULL  
  fileName <- paste("/Users/admin/Documents/stockdata_oj/", format(targetDay), "_ose.csv", sep="")
  
  tryCatch({ 
    oseStockData <- read.csv(fileName , header = FALSE , skip = 1, colClasses = "character",fileEncoding = "utf-8" )
    dbGetPreparedQuery(conn, "INSERT INTO stockData VALUES( :V1 , :V2 ,:V3, :V4, :V5, :V6 , :V7 ,:V8, :V9, :V10, :V11)", bind.data=oseStockData)
  },  
  error = function(e) {
  })
  
  targetDay <- targetDay + 1
}

dbCommit(conn)  
dbDisconnect(conn)
