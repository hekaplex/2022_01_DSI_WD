#Troubleshooting OS Error
#Working Copy  2022-02-25 0900AM
#pip install BeautifulSoup as b  & #pip install requests

from bs4 import BeautifulSoup as b
import numpy as np
import requests as r
import pandas as p
import math as m
import csv as cv
from datetime import date, timedelta, datetime

# getting search days from user
def getDates(txt):
    msg1 = 'Enter the search ' + txt + ' in YYYY-MM-DD format'
    startDate = input(msg1)
    gDate = 0 

    while gDate != 1:
        try:
            Syear, Smonth, Sday = map(int, startDate.split('-'))
            date1 = date(Syear, Smonth, Sday)
        except: 
            startDate = input(msg1)
            continue
        gDate = 1 
    return date1
date1 = getDates('startDate')
date2 = getDates('endDate')

#Get new search string
base = date1
stringA = "https://www.fpds.gov/ezsearch/fpdsportal?q=+SIGNED_DATE%3A%5B"
base = date1
endt = date2
stringB = str(base.year)+"%2F"+base.strftime("%m") + "%2F" + base.strftime("%d") + "%2C"+str(endt.year)+"%2F" + endt.strftime("%m") + "%2F" +endt.strftime("%d") + "%5D&s=FPDS.GOV&templateName=1.5.2&indexName=awardfull&x=30&start="
stringC = '30'
myURLsearch = (stringA + stringB + stringC)
myURLsearch
downloadURL = r.get(myURLsearch,headers={})
soup = b(downloadURL.text,"html.parser")
#CSS
fulltable_select  = soup.select('span.results_heading')
myLen = m.ceil(int(fulltable_select[1].find_all('b')[2].text))
print(myLen)

runInt = 1
wID = 0
while wID < myLen + 60:
    #endt = base + timedelta(days=1)
    stringB = str(base.year)+"%2F"+base.strftime("%m") + "%2F" + base.strftime("%d") + "%2C"+str(endt.year)+"%2F" + endt.strftime("%m") + "%2F" +endt.strftime("%d") + "%5D&s=FPDS.GOV&templateName=1.5.2&indexName=awardfull&x=24&y=7&start="
    stringC = int(stringC) + 30
    stringC = str(stringC)
    myURLsearch = (stringA + stringB + stringC)
    downloadURL = r.get(myURLsearch,headers={})
    soup = b(downloadURL.text,"html.parser")
    fulltable_select  = soup.select('span.results_text')
    datalist = []
    slop =[]
    for d in fulltable_select: 
        try: 
            datalist.append(d.a.contents)
        except:
            try:
                datalist.append(d.span.contents)
            except:
                #formerly known as slop
                datalist.append(str(d.contents).replace("\\t","").replace("\\n","").replace("[","").replace("]","").replace("\'",""))
            continue
    
    try:
        newlist = ["".join(d) if type(d) is list else d for d in datalist ]
        #try block as just-in-case the field return is not 19
        
        dlarr = np.array(newlist).reshape(m.floor(len(newlist)/19),19)
            
        #Get Dataframe
        df = p.DataFrame(data= dlarr
        , columns=['AwardID','AwardType','LegalBusinessName','ContractingAgency','DateSigned','ActionObligation','ReferencedIDV','ContractingOffice','NAICS_Code','PSC_Code','EntityCity','UniqueEntityID_DUNS', 'EntityState','UniqueEntityID_SAM','Zip','UltimateParentUniqueEntityID_DUNS','UltimateParentLegalBusinessName','UltimateParentUniqueEntityID_SAM','CAGE_Code']
        )
        r2 = datetime.today().strftime("%Y%m%d%H%M%S")
                
        # Create run interval interger
        if wID < 1:
            fileName = 'fpds_ng_' + r2 + '.csv'
            df.to_csv(fileName,index = False)
            wID = wID + 30
        else:
            with open(fileName, "a", newline="") as file:
                writer = cv.writer(file,delimiter= ",",)
                writer.writerows(dlarr)
            wID = wID + 30
            
    except:
        print("Skipping records at range - " + str(wID))
        continue