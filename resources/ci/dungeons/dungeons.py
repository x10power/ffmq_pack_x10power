'''
Document chest names
'''
import pyjson5
import os

base_path = os.path.join(
    ".",
    "locations"
)

dungeons = {
    "earth/bonedungeon",
    "water/icepyramid",
    "fire/lava-dome",
    "wind/giant-tree",
    "wind/mac-ship",
    "wind/pazuzu-tower",
    "center/doom-castle"
}

usedNames = []
dupeNames = []

for dungeon in dungeons:
    with open(
        os.path.join(
            base_path,
            dungeon + ".json"
        ),
        mode="r",
        encoding="utf-8"
    ) as dungeonFile:
        dungeonJSON = pyjson5.decode_io(dungeonFile)
        for dDefn in dungeonJSON:
            print(dDefn["name"])
            for dKid in dDefn["children"]:
                # print(" " + dKid["name"])
                if "children" in dKid:
                    for dKidKid in dKid["children"]:
                        # print("  " + dKidKid["name"])
                        for dKidKidSec in dKidKid["sections"]:
                            # print("   " + dKidKidSec["name"])
                            locName = ""
                            locName = locName + "@"
                            locName = locName + dKid["name"]
                            if dKidKid["name"] not in locName:
                                locName = locName + "/" + dKidKid["name"]
                            locName = locName + "/" + dKidKidSec["name"]
                            if locName in usedNames:
                                print("!!! " + locName)
                                dupeNames.append(locName)
                            else:
                                usedNames.append(locName)
                            print(locName)
    print()
print(dupeNames)
