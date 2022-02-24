#pip install BeautifulSoup as b
from bs4 import BeautifulSoup as b
#pip install requests
import requests as r
import pandas as p

myURL= 'https://www.fpds.gov/ezsearch/fpdsportal?indexName=awardfull&templateName=1.5.2&s=FPDS.GOV&q=+SIGNED_DATE%3A%5B2019%2F10%2F30%2C2022%2F02%2F28%5D&x=24&y=7'
downloadURL = r.get(myURL,headers={})
soup = b(downloadURL.text,"html.parser")

fullTable = soup.select('<span class="results_text">')[0]
driver=fullTable.select('a span')

tableRows = []

for d in driver
    tableRows.append(str(d).replace('<span class="standing-table_cell--name-text">','').replace('</span>','').strip())

df = p.DataFrame(tableRows, columns=[ContractID])


print(df)
