import requests
import urllib
from requests import Response
from bs4 import BeautifulSoup
import html5lib
#query = "hackernoon How To Scrape Google With Pithon"
# query = query.replace("", "+")
# URL = f"https://www.tripadvisor.ru/Attractions-g298484-Activities-c47-Moscow_Central_Russia.html"
# USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 YaBrowser/24.1.0.0 Safari/537.36"
# headers = {"user-agent": USER_AGENT}
# resp = requests.get(URL, headers=headers)
# if resp.status_code == 200:
#     soup = BeautifulSoup(resp.content, "html.parser")
# results = []
# for g in soup.find_all("div", class_="r"):
#     anchors = g.find_all("a")
#     if anchors:
#         link = anchors[0]["href"]
#         title = g.find_all("h3").text
#         item = {
#             "title": title,
#             "link": link
#         }
#         results.append(item)
# print(results)


# URL = "https://www.google.ru/search?q=достопримечательности&newwindow=1&sca_esv=97a1783dabf6226b&sxsrf=ACQVn08qk6SUH35_BjgZ_L6jrXLAF2U3sg%3A1707659675424&source=hp&ei=m9HIZY-KGMvawPAPsI6O-AE&iflsig=ANes7DEAAAAAZcjfq1MZ52KtDnaHjPJxmWSzROAputae&udm=&ved=0ahUKEwjPw-WCuKOEAxVLLRAIHTCHAx8Q4dUDCA0&uact=5&oq=достопримечательности&gs_lp=Egdnd3Mtd2l6IirQtNC-0YHRgtC-0L_RgNC40LzQtdGH0LDRgtC10LvRjNC90L7RgdGC0LgyChAjGIAEGIoFGCcyCxAAGIAEGIoFGJIDMgsQABiABBiKBRiSAzIFEAAYgAQyCxAAGIAEGLEDGMkDMgUQABiABDIIEAAYgAQYsQMyCxAAGIAEGLEDGIMBMgsQABiABBixAxiDATIFEAAYgARIpkNQggZYtztwAXgAkAEAmAFPoAGXC6oBAjIxuAEDyAEA-AEBqAIKwgIHECMY6gIYJ8ICExAuGIAEGIoFGMcBGK8BGI4FGCfCAhEQLhiABBixAxiDARjHARjRA8ICBBAjGCfCAgsQLhiABBjHARivAcICCxAuGIAEGLEDGIMBwgILEC4YgwEYsQMYgATCAggQABiABBjJAw&sclient=gws-wiz"
# r = requests.get(URL)
# soup = str(BeautifulSoup(r.content, "html5lib"))
#
# Ad = str.find("a", attrs={"jsname": "UWckNb"})
# print(Ad)
url = 'https://www.google.ru/search?q=достопримечательности&newwindow=1&sca_esv=97a1783dabf6226b&sxsrf=ACQVn08qk6SUH35_BjgZ_L6jrXLAF2U3sg%3A1707659675424&source=hp&ei=m9HIZY-KGMvawPAPsI6O-AE&iflsig=ANes7DEAAAAAZcjfq1MZ52KtDnaHjPJxmWSzROAputae&udm=&ved=0ahUKEwjPw-WCuKOEAxVLLRAIHTCHAx8Q4dUDCA0&uact=5&oq=достопримечательности&gs_lp=Egdnd3Mtd2l6IirQtNC-0YHRgtC-0L_RgNC40LzQtdGH0LDRgtC10LvRjNC90L7RgdGC0LgyChAjGIAEGIoFGCcyCxAAGIAEGIoFGJIDMgsQABiABBiKBRiSAzIFEAAYgAQyCxAAGIAEGLEDGMkDMgUQABiABDIIEAAYgAQYsQMyCxAAGIAEGLEDGIMBMgsQABiABBixAxiDATIFEAAYgARIpkNQggZYtztwAXgAkAEAmAFPoAGXC6oBAjIxuAEDyAEA-AEBqAIKwgIHECMY6gIYJ8ICExAuGIAEGIoFGMcBGK8BGI4FGCfCAhEQLhiABBixAxiDARjHARjRA8ICBBAjGCfCAgsQLhiABBjHARivAcICCxAuGIAEGLEDGIMBwgILEC4YgwEYsQMYgATCAggQABiABBjJAw&sclient=gws-wiz'
r = requests.get(url, timeout=5)

if r.status_code == 200:
    soup_ing = str(BeautifulSoup(r.content, 'lxml'))
    soup_ing = soup_ing.encode()
    with open("test.html", "wb") as file:
        file.write(soup_ing)

    def fromSoup():
        html_file = ("test.html")
        html_file = open(html_file, encoding='UTF-8').read()
        soup = BeautifulSoup(html_file, 'lxml') # name of our soup

        for link in soup.find_all('a'):
            print(link.get('href'))

    fromSoup()

print("РЕСТОРАНЫ")

url = "https://www.google.ru/search?q=все+рестораны+мира&newwindow=1&sca_esv=97a1783dabf6226b&sxsrf=ACQVn0-j2kweOd3dMXyL6rw_g7-MoUO3-g%3A1707663315010&ei=09_IZdQg1qjA8A_psoCwBA&udm=&ved=0ahUKEwiU1qXKxaOEAxVWFBAIHWkZAEYQ4dUDCBA&uact=5&oq=все+рестораны+мира&gs_lp=Egxnd3Mtd2l6LXNlcnAiItCy0YHQtSDRgNC10YHRgtC-0YDQsNC90Ysg0LzQuNGA0LAyBBAAGB5Iqw9QowVYxgxwAXgBkAEAmAF5oAGQA6oBAzIuMrgBA8gBAPgBAcICChAAGEcY1gQYsAPCAg0QABiABBiKBRhDGLADwgIHECMYsAIYJ8ICBxAAGIAEGA3CAgYQABgHGB7CAggQABgIGAcYHsICChAAGAgYBxgeGAriAwQYACBBiAYBkAYJ&sclient=gws-wiz-serp"
r = requests.get(url, timeout=5)


if r.status_code == 200:
    soup_ing = str(BeautifulSoup(r.content, 'lxml'))
    soup_ing = soup_ing.encode()
    with open("test.html", "wb") as file:
        file.write(soup_ing)

    def fromSoup():
        html_file = ("test.html")
        html_file = open(html_file, encoding='UTF-8').read()
        soup = BeautifulSoup(html_file, 'lxml') # name of our soup

        for link in soup.find_all('a'):
            print(link.get('href'))

    fromSoup()