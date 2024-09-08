import json
import os
from pathlib import Path
from PIL import Image, ImageDraw
import re
from yaml import load, dump
from yaml import CLoader as Loader, CDumper as Dumper

import common.autoformat as autoformat

paths = [
    os.path.join(".","resources","ci","dungeons","manifests"),
    os.path.join(".","resources","ci","settlements","manifests")
]

for seekPath in paths:
    for path in sorted(Path(seekPath).glob("**/*.yaml")):
        with open(path) as dungeonFile:
            region = list(os.path.splitext(os.path.basename(path)))[0]
            mapType = seekPath.split(os.sep)[3]
            dungeonYAML = load(dungeonFile.read(), Loader=Loader)
            for [dungeonName, floors] in dungeonYAML.items():
                if floors:
                    destPath = os.path.join(
                        ".",
                        "images",
                        "maps",
                        mapType,
                        dungeonName
                    )
                    if not os.path.isdir(destPath):
                        os.makedirs(destPath)
                    mapsData = []
                    tabsData = []
                    for [floorID, connections] in floors.items():
                        if connections:
                            mapsData.append(
                                {
                                    "name": dungeonName + "-" + floorID.lower(),
                                    "img": f"images/maps/{mapType}/{dungeonName}/{dungeonName}-" + floorID.lower() + ".png",
                                    "location_border_thickness": 1,
                                    "location_size": 16
                                }
                            )
                            floorTitle = ""
                            floorNum = floorID
                            if floorID.lower() != "boss":
                                if floorID[:1].upper() == "B":
                                    # basement
                                    floorNum = "B" + floorID[1:]
                                    floorTitle += "Basement" if len(floorNum) == 2 else "Room"
                                else:
                                    # floor
                                    # ends with F: nuke F
                                    if floorNum[len(floorNum)-1:] == "f":
                                        # ends with FF: keep F
                                        if floorNum[len(floorNum)-2:] == "ff":
                                            floorTitle = "Room"
                                        else:
                                            floorNum = floorNum[:len(floorNum)-1]
                                    else:
                                        floorTitle = "Room"
                            capSet = 1
                            if re.search(r'\d', floorNum):
                                capSet = 2
                            if len(floorNum) == 1:
                                floorTitle = "Floor"
                            elif floorNum[:1].upper() == "A":
                                floorTitle = "Area"
                                floorNum = floorNum[1:]
                            elif floorNum.lower() in [
                                "deck",
                                "outside",
                                "stairs"
                            ]:
                                floorTitle = floorNum[:1].upper() + floorNum[1:]
                                floorNum = ""
                            floorTitle += " " + floorNum[:capSet].upper() + floorNum[capSet:].lower()

                            tabsData.append(
                                {
                                    "title": floorTitle.strip(),
                                    "content": {
                                        "type": "map",
                                        "maps": [
                                            dungeonName + "-" + floorID.lower()
                                        ]
                                    }
                                }
                            )
                            with Image.open(
                                os.path.join(
                                    ".",
                                    "resources",
                                    "app",
                                    "images",
                                    "maps",
                                    mapType,
                                    region,
                                    dungeonName,
                                    dungeonName + "-" + floorID + ".png"
                                )
                            ) as annotatedImg:
                                annotatedImg = annotatedImg.convert("RGBA")
                                for [connectID, destinations] in connections.items():
                                    if not isinstance(destinations, list):
                                        destinations = [destinations]
                                    for destination in destinations:
                                        if destination:
                                            if connectID not in ["note"]:
                                                capSet = 1
                                                if re.search(r'\d', connectID):
                                                    capSet = 2
                                                connectID = connectID[:capSet].upper() + connectID[capSet:].lower()
                                                connectSize = (40,40)
                                                with Image.new(
                                                    "RGBA",
                                                    connectSize,
                                                    (0,0,0,0)
                                                ) as connectImg:
                                                    bold = True
                                                    d = ImageDraw.Draw(connectImg)
                                                    d.ellipse(
                                                        (
                                                            0,
                                                            0,
                                                            (connectSize[0] - 1),
                                                            (connectSize[1] - 1)
                                                        ),
                                                        fill="red",
                                                        outline="red"
                                                    )
                                                    connectText = connectID
                                                    if connectText == "Stairs":
                                                        connectText = "Stair"
                                                    d.text(
                                                        (
                                                            int(connectSize[0] / 2),
                                                            int(connectSize[1] / 2)
                                                        ),
                                                        connectText,
                                                        fill=(255,255,255,255),
                                                        anchor="mm",
                                                        font_size=16,
                                                        stroke_width=1 if bold else 0,
                                                        stroke_fill=(0,0,0,255)
                                                    )
                                                    annotatedImg.paste(
                                                        connectImg,
                                                        (
                                                            int(destination["x"] - (connectSize[0] / 2)),
                                                            int(destination["y"] - (connectSize[1] / 2))
                                                        ),
                                                        connectImg
                                                    )
                                                    print(dungeonName, floorID, connectID, destination)
                                annotatedImg.save(
                                    os.path.join(
                                        destPath,
                                        dungeonName + "-" + floorID + ".png"
                                    )
                                )
                    with open(
                        os.path.join(
                            ".",
                            "maps",
                            mapType,
                            dungeonName.replace("-","") + ".json"
                        ),
                        "w"
                    ) as mapsJSON:
                        mapsJSON.write(json.dumps(mapsData, indent=2))
                        mapsJSON.write("\n")
                    with open(
                        os.path.join(
                            ".",
                            "layouts",
                            "maps",
                            mapType,
                            region,
                            dungeonName.replace("-","") + ".json"
                        ),
                        "w"
                    ) as tabsJSON:
                        mapKey = dungeonName.replace("-","_")
                        if mapType == "dungeons":
                            mapKey = f"maps_{mapKey}"
                        elif mapType == "settlements":
                            mapKey = f"settlements_{mapKey}"
                        tabsJSON.write(json.dumps(
                            {
                                mapKey: {
                                    "type": "tabbed",
                                    "tabs": tabsData
                                }
                            }
                        , indent=2))
                        tabsJSON.write("\n")

autoformat.autoformat()
