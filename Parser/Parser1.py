
import requests
from bs4 import BeautifulSoup
url = requests.get("https://bolshayastrana.com/regiony")
soup = BeautifulSoup(url.content, "html.parser")
balances = soup.find_all('div', {"class": "region-card__body-title"})
for balance in balances:
    print(balance.text)


