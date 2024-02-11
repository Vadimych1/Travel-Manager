import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import time
import pickle


def main(request):
    options = Options()
    options.headless = True
    options.add_argument("--window-size=1920,1200")

    driver = webdriver.Chrome(options=options)
    s_b = driver.find_element_by_css_selector("№root")
    s_b.send_key("selenium python")
    s_b.submit()


if __name__ == "__main__": main("request")
