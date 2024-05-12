import json
import os

from flatten_json import flatten

typeDefnsPath = os.path.join(".","resources","app","meta","manifests","loctypes.json")
with open(typeDefnsPath, "r") as typeDefnsFile:
    typeDefnsJSON = json.load(typeDefnsFile)

dirname = os.path.join(".", "locations")
for r, d, f in os.walk(dirname):
    if "main.json" in f:
        f.pop(f.index("main.json"))
        f.reverse()
        f.append("main.json")
        f.reverse()
    for filename in f:
        if os.path.isfile(os.path.join(r, filename)):
            if os.path.splitext(filename)[1].lower() == ".json":
                print(f"Reading: {os.path.join(r, filename)}")
                with open(os.path.join(r, filename), "r", encoding="utf-8") as locsFile:
                    locsManifest = json.load(locsFile)
                    flattened_dict = [
                        flatten(d, '.') for d in locsManifest
                    ][0]

                    locName = ""
                    locTree = ""
                    typeName = ""
                    typeCheck = ""
                    typeCheckPass = 0

                    hasSections = False
                    notChest = False

                    for [k, v] in flattened_dict.items():
                        if ".name" in k:
                            if v not in ["Box","Item"]:
                                for checkType in [
                                    "Chest",
                                    "Old Man",
                                    "Blue Man",
                                    "Kaeli",
                                    "Phoebe",
                                    "Reuben",
                                    "Tristam",
                                    "Spencer"
                                ]:
                                    if checkType in v:
                                        if locName != "" and locName != v:
                                            if typeName == "":
                                                print(f"🔴{locName} no type set!")
                                            if typeCheck != "" and \
                                                typeCheck in list(typeDefnsJSON.keys()) and \
                                                typeCheck != "default" and \
                                                typeCheckPass < len(typeDefnsJSON[typeCheck]) - 1:
                                                print(f"🔴{locName}: '{typeCheck}' images not set!")
                                        locName = v
                                        locTree = k
                                        typeName = ""
                                        typeCheckPass = 0
                                if locName != "" and \
                                    "Box" not in v:
                                    pass
                        if locName != "":
                            if ".#type" in k:
                                typeName = v
                                if typeName in list(typeDefnsJSON.keys()):
                                    typeCheck = typeName
                                    typeCheckPass = 0
                                # print(f"🟡{locName}",v)
                            if "_img" in k:
                                imgType = k.split(".")[-1]
                                if typeCheck != "":
                                    if imgType in typeDefnsJSON[typeCheck]:
                                        if typeDefnsJSON[typeCheck][imgType] == v:
                                            typeCheckPass += 1
                                    else:
                                        print(f"🟡{locName}: Image Type '{imgType}' not found in '{typeCheck}' defn!")
                                else:
                                    print(f"🟡{locName}",k,v)
