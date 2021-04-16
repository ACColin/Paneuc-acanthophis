import json
import os
import requests

with open("gundh.json") as fh:
    j = json.load(fh)

os.makedirs("photos", exist_ok=True)

print("photo", "lat", "long", "date", sep='\t')
for p in j["initialExploreMap"]["mapPhotos"]:
    #print(json.dumps(p, indent=4))
    id = p["photo"]["id"]
    name = p["photo"]["title"]
    hash = p["photo"]["photoHash"]
    lat = p["location"]["latitude"]
    long = p["location"]["longitude"]
    date = p["photo"]["metadata"]["created"]
    url = f"https://cdn-assets.alltrails.com/uploads/photo/image/{id}/extra_large_{hash}.jpg"
    fname = f"photos/{name}"
    r = requests.get(url)
    with open(fname, "wb") as fh:
        fh.write(r.content)
    print(name, lat, long, date, sep="\t")

