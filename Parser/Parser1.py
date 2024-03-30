import requests
import urllib
from requests import Response
from bs4 import BeautifulSoup
import html5lib
# import selenium.webdriver as webdriver

# driver = webdriver.Chrome()

def repair_link(url: str) -> str:
    url = urllib.parse.unquote(url)

    if url.startswith("/url?q="):
        url = url.replace("/url?q=", "")

        if "google.com" in url or "google.ru" in url:
            return ""
        
        return url if url.startswith("http") else ""
    else:
        return ""
    
def repair_links(urls: list) -> list:
    new_urls = []
    for link in urls:
        rep = repair_link(link)

        if rep != "":
            new_urls.append(rep)
    
    return new_urls

def get_links(url: str) -> list:
    r = requests.get(url, timeout=5)

    if r.status_code == 200:
        soup = BeautifulSoup(r.content, 'lxml')
        
        links = [link.get('href') for link in soup.find_all('a')]
        return repair_links(links)
    else:
        print("Error: ", r.status_code)
        return []

def get_names(links: list) -> list:
    results = []

    for link in links:
        try:
            r = requests.get(link, timeout=5)
        except:
            continue

        soup = BeautifulSoup(r.content, 'lxml')

        for elem in soup.find_all("h1"):
            results.append(elem.text)

        for elem in soup.find_all("h2"):
            results.append(elem.text)

        for elem in soup.find_all("h3"):
            results.append(elem.text)

    return results

url = 'https://www.google.ru/search?q=достопримечательности+москвы&newwindow=1&sca_esv=97a1783dabf6226b&sxsrf=ACQVn08qk6SUH35_BjgZ_L6jrXLAF2U3sg%3A1707659675424&source=hp&ei=m9HIZY-KGMvawPAPsI6O-AE&iflsig=ANes7DEAAAAAZcjfq1MZ52KtDnaHjPJxmWSzROAputae&udm=&ved=0ahUKEwjPw-WCuKOEAxVLLRAIHTCHAx8Q4dUDCA0&uact=5&oq=достопримечательности&gs_lp=Egdnd3Mtd2l6IirQtNC-0YHRgtC-0L_RgNC40LzQtdGH0LDRgtC10LvRjNC90L7RgdGC0LgyChAjGIAEGIoFGCcyCxAAGIAEGIoFGJIDMgsQABiABBiKBRiSAzIFEAAYgAQyCxAAGIAEGLEDGMkDMgUQABiABDIIEAAYgAQYsQMyCxAAGIAEGLEDGIMBMgsQABiABBixAxiDATIFEAAYgARIpkNQggZYtztwAXgAkAEAmAFPoAGXC6oBAjIxuAEDyAEA-AEBqAIKwgIHECMY6gIYJ8ICExAuGIAEGIoFGMcBGK8BGI4FGCfCAhEQLhiABBixAxiDARjHARjRA8ICBBAjGCfCAgsQLhiABBjHARivAcICCxAuGIAEGLEDGIMBwgILEC4YgwEYsQMYgATCAggQABiABBjJAw&sclient=gws-wiz'
# url = "https://www.google.ru/search?q=все+рестораны+мира&newwindow=1&sca_esv=97a1783dabf6226b&sxsrf=ACQVn0-j2kweOd3dMXyL6rw_g7-MoUO3-g%3A1707663315010&ei=09_IZdQg1qjA8A_psoCwBA&udm=&ved=0ahUKEwiU1qXKxaOEAxVWFBAIHWkZAEYQ4dUDCBA&uact=5&oq=все+рестораны+мира&gs_lp=Egxnd3Mtd2l6LXNlcnAiItCy0YHQtSDRgNC10YHRgtC-0YDQsNC90Ysg0LzQuNGA0LAyBBAAGB5Iqw9QowVYxgxwAXgBkAEAmAF5oAGQA6oBAzIuMrgBA8gBAPgBAcICChAAGEcY1gQYsAPCAg0QABiABBiKBRhDGLADwgIHECMYsAIYJ8ICBxAAGIAEGA3CAgYQABgHGB7CAggQABgIGAcYHsICChAAGAgYBxgeGAriAwQYACBBiAYBkAYJ&sclient=gws-wiz-serp"

print(*get_names(get_links(url)))