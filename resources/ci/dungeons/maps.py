import json
import os
from PIL import Image
from yaml import load, dump
from yaml import CLoader as Loader, CDumper as Dumper

with open(
    os.path.join(
        ".",
        "resources",
        "ci",
        "dungeons",
        "manifests",
        "bone-dungeon.yaml"
    )
) as dungeonFile:
    dungeonYAML = load(dungeonFile.read(), Loader=Loader)
    for [region, dungeon] in dungeonYAML.items():
        for [dungeonName, floors] in dungeon.items():
            # images\maps\dungeons\bone-dungeon
            destPath = os.path.join(
                ".",
                "images",
                "maps",
                "dungeons",
                dungeonName
            )
            if not os.path.isdir(destPath):
                os.makedirs(destPath)
            mapsData = []
            tabsData = []
            for [floorID, connections] in floors.items():
                mapsData.append(
                    {
                        "name": dungeonName + "-" + floorID.lower(),
                        "img": "images/maps/dungeons/" + dungeonName + "/" + dungeonName + "-" + floorID.lower() + ".png",
                        "location_border_thickness": 1,
                        "location_size": 16
                    }
                )
                floorTitle = "Floor " + floorID[:2].upper() + floorID[2:]
                if floorID == "boss":
                    floorTitle = "Boss"
                tabsData.append(
                    {
                        "title": floorTitle,
                        "content": {
                            "type": "map",
                            "maps": [
                                dungeonName + "-" + floorID.lower()
                            ]
                        }
                    }
                )
                annotatedImg = Image.open(
                    os.path.join(
                        ".",
                        "resources",
                        "app",
                        "images",
                        "maps",
                        "dungeons",
                        region,
                        dungeonName,
                        dungeonName + "-" + floorID + ".png"
                    )
                )
                annotatedImg = annotatedImg.convert("RGBA")
                for [connectID, connection] in connections.items():
                    if connectID not in ["note", "exit"]:
                        connectFolder = ""
                        if connectID == "boss":
                            connectID = "Boss"
                            connectFolder = connectID
                        else:
                            connectID = connectID.upper()
                            connectFolder = connectID[:2]
                        connectFolder = connectFolder.lower()
                        connectImg = Image.open(
                            os.path.join(
                                ".",
                                "images",
                                "icons",
                                connectFolder,
                                "icon" + connectID + ".png"
                            )
                        )
                        connectSize = (32,32)
                        connectImg = connectImg.resize(
                            connectSize,
                            Image.Resampling.NEAREST
                        )
                        annotatedImg.paste(
                            connectImg,
                            (
                                int(connection["x"] - (connectSize[0] / 2)),
                                int(connection["y"] - (connectSize[1] / 2))
                            ),
                            connectImg
                        )
                        print(dungeonName, floorID, connectID, connection)
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
                    "dungeons",
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
                    "dungeons",
                    region,
                    dungeonName.replace("-","") + ".json"
                ),
                "w"
            ) as tabsJSON:
                tabsJSON.write(json.dumps(
                    {
                        "maps_bone_dungeon": {
                            "type": "tabbed",
                            "tabs": tabsData
                        }
                    }
                , indent=2))
                tabsJSON.write("\n")
