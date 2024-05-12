import json
import os

from flatten_json import flatten

typeDefnsPath = os.path.join(".","resources","app","meta","manifests","loctypes.json")
with open(typeDefnsPath, "r") as typeDefnsFile:
    typeDefnsJSON = json.load(typeDefnsFile)

print("Reading Location Image Types")
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
                print(f" Reading: {os.path.join(r, filename)}")
                with open(os.path.join(r, filename), "r", encoding="utf-8") as locsFile:
                    locsManifest = json.load(locsFile)
                    flattened_dict = [
                        flatten(d, '.') for d in locsManifest
                    ][0]

                    locName = ""
                    locTree = ""
                    typeName = ""
                    typeCheck = ""
                    typesChecked = []
                    typeCheckPass = 0

                    hasSections = False
                    notChest = False

                    for [k, v] in flattened_dict.items():
                        if ".name" in k:
                            if v not in ["Box"]:
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
                                                print(f"  🔴{locName} no type set!")
                                            if typeCheck != "" and \
                                                typeCheck != "default" and \
                                                typeCheck in list(typeDefnsJSON.keys()) and \
                                                typeCheckPass < len(typeDefnsJSON[typeCheck]) - 1:
                                                typesNotChecked = list(set(list(typeDefnsJSON[typeCheck].keys())) - set(typesChecked))
                                                if "moo" in typesNotChecked:
                                                    del typesNotChecked[typesNotChecked.index("moo")]
                                                print(f"  🔴{locName}: '{typeCheck}' properties not set! {typesNotChecked}")
                                        locName = v
                                        locTree = k
                                        typeName = ""
                                        typesChecked = []
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
                                # print(f"  🟡{locName}",v)
                            if typeCheck != "":
                                baseK = k.split(".")
                                baseK.pop()
                                propType = k.split(".")[-1]
                                if propType.isnumeric():
                                    propType = k.split(".")[-2]
                                if propType in typeDefnsJSON[typeCheck]:
                                    if typeDefnsJSON[typeCheck][propType] == v:
                                        typeCheckPass += 1
                                        typesChecked.append(propType)
                                        # print(f"  🟢{locName}: Property Type '{propType}' set!")
                                    else:
                                        handleK = "locsManifest[0]"
                                        lastK = baseK.pop()
                                        for partK in baseK:
                                            if partK.isnumeric():
                                                handleK += f"[{partK}]"
                                            else:
                                                handleK += f"[\"{partK}\"]"
                                        if "sections" not in baseK and \
                                            lastK in eval(handleK):
                                            # print(handleK,lastK)
                                            typeCheckPass += 1
                                            typesChecked.append(propType)
                                            pass
                                        else:
                                            # print(f"  🔴{locName}: Property Type '{propType}' invalid value [{type(v)}: {v}]!")
                                            pass
print("")
