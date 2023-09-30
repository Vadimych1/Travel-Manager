import requests
import json
import codecs

MAPS_API_KEY = ""
with open("./services/maps.key", "r", -1, "utf-8") as f:
    MAPS_API_KEY = f.readline()

PLACES_API = "https://catalog.api.2gis.com/3.0/items?"


def search(city, item):
    res = requests.get(
        PLACES_API +
        f"q={city+' '+item}&type=branch&fields=items.point,items.address,items.schedule&key={MAPS_API_KEY}"
    ).text

    res_s = codecs.decode(res, 'unicode_escape')

    return json.loads(res_s)


def compute(search_result):
    s = search_result

    meta = s["meta"]

    if meta["code"] == 200:
        result = s["result"]
        items = result["items"]

        senddata = {"places": []}

        for item in items:
            address = item["address"]

            try:
                address_comment = item["address_comment"]
            except:
                address_comment = ""

            try:
                address_name = item["address_name"]
            except:
                address_name = ""

            try:
                about = item["ads"]
            except:
                about = ""
            
            try:
                company_name = item["name"]
            except:
                company_name = ""

            point = item["point"]

            try:
                schedule = item["schedule"]
            except:
                schedule = ""

            try:
                building_name = address["building_name"]
            except:
                building_name = ""

            senddata['places'].append({
                "address_name": address_name,
                "address_comment": address_comment,
                "building_name": building_name,
                "about": about,
                "company": company_name,
                "lat": point["lat"],
                "lon": point["lon"],
                "schedule": schedule,
            })

        senddata["code"] = 1
        senddata["results_n"] = result["total"]

    else:
        return None

    return json.dumps(senddata)


def fullsearch(city, item):
    res = compute(search(city, item))
    return res if res is not None else '{"code":0}'


while True:
    print(fullsearch(input("Город > "), input("Место > ")))