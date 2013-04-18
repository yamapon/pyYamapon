import re
from urllib import urlopen
from datetime import date
from datetime import timedelta
from time import strftime
import httplib,urlparse
import os

tsdurl = "https://www.release.tdnet.info/inbs/"
maindir = "d:\\tsddata\\"

def filedownload( date ,filename ):
    import urllib 
   
    res = urllib.urlopen( tsdurl + filename ).read()
    dest = file( maindir + date +"\\" + filename, "wb")
    dest.write(res)
    dest.close()

def httpExists(url):

    host,path = urlparse.urlsplit(url)[1:3]
    port = None
    try:
        connection = httplib.HTTPConnection(host,port=port)
        connection.request("head", path)
        resp = connection.getresponse()
        if resp.status == 200:
            found = True
        elif resp.status == 302:
            found = httpExist(urlparse.urljoin(url,resp.getheader('location','')))
        else:
            found = False
    except Exception,e:
        print e.__class__,e,url
        found = False
    return found
    
def httpCheck(url):

    httpcode = urlopen(url)
    info = httpcode.read()
    p = re.compile(r'<TITLE>404 Not Found</TITLE>')
    if len( p.findall(info) ) > 0 :
        result = False
    else:
        result = True   
    return result
    
def makeFileList(date,fileList):
    
    dest = file( maindir + "\\fileList"+ date +".csv" , "w")
    for res in fileList:
        dest.write(res + "," )
    dest.close()

if __name__ == "__main__":
    
    d = date.today() - timedelta(days=1)
    strdate = d.strftime("%Y%m%d")
    while(True):
        if os.path.exists( maindir + strdate ) == False:
            os.mkdir( maindir + strdate )
 
            print "Date: %s " % strdate
        
            fileList = []
            count = 1
            while(True):
                page = "%03d"  % ( count )
                url = tsdurl + "I_list_" + page + "_" + str(strdate) + ".html"
        
                if httpCheck(url) == False :
                    print "Read all finished..."
                    break
        
                f = urlopen(url)
                code = f.read()
                regexp = re.compile(r'\d*\.zip')
                for result in regexp.findall(code):
                    fileList.append(result)
                    filedownload( strdate, result)    
                makeFileList( strdate , fileList)
                print "Page: %s done..." % page
                count += 1

            d = d -  timedelta(days=1)
            strdate = d.strftime("%Y%m%d")

        else:
            break
    