library("RSQLite")

drv <- dbDriver("SQLite", max.con = 1)
conn <- dbConnect(drv, dbname="db.stockdata")

rs <- dbSendQuery( conn,
                   "CREATE TABLE stockIndex (
                   date TEXT,
                   code TEXT,
                   open NUMERIC,
                   high NUMERIC,
                   low NUMERIC,
                   close NUMERIC,
                   primary key(date, code)
);"
)
rs <- dbSendQuery( conn, "create index indexIDX on stockIndex(date, code);")

rs <- dbSendQuery( conn,
                   "CREATE TABLE stockData (
                   date TEXT,
                   code TEXT,
                   name TEXT,
                   market TEXT,
                   sector TEXT,
                   open NUMERIC,
                   high NUMERIC,
                   low NUMERIC,
                   close NUMERIC,
                   volume NUMERIC,
                   tradingvol NUMERIC,
                   primary key(date, code, market)
);"
)

rs <- dbSendQuery( conn, "create index stockIDX on stockData(date, code);")
