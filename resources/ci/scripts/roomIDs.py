import natsort
import os
import re
import ssl
import urllib.request

from yaml import load, dump
from yaml import CLoader as Loader, CDumper as Dumper

roomYAMLUrl = "https://github.com/wildham0/FFMQRando/raw/master/FFMQRLib/datafiles/rooms.yaml"

context = ssl._create_unverified_context()
roomReq = urllib.request.urlopen(roomYAMLUrl, context=context)
locations = {
    "battlefield": {},
    "item": {},
    "npc": {}
}
if roomReq:
    roomYAML = load(roomReq.read(), Loader=Loader)
    lines = []
    lines.append("roomIDs = {")
    lines.append("  [\"battlefields\"] = {")
    startedRooms = False
    usedIDs = []
    for room in roomYAML:
        if "game_objects" in room:
            for gObj in room["game_objects"]:
                if "object_id" in gObj:
                    if gObj["object_id"] >= 0:
                        locType = gObj["type"].lower()
                        if "battlefield" in locType:
                            locType = "battlefield"
                        if locType in ["chest","box"]:
                            locType = "item"
                        if locType in locations:
                            gID = str(gObj["object_id"])
                            rName = "@" + room["name"]
                            gName = gObj["name"]
                            if "-" in rName:
                                rName = rName[:rName.find("-") - 1].strip()
                            if "-" in gName:
                                gName = gName[gName.find("-") + 1:].strip()
                            match = re.match(r"^(\@[^\d\@\\]+)([B\d]+)([\dF]+)", rName)
                            if match:
                                rName = match.group(1)  # Room Name
                                fLevel = match.group(2) # Floor Level
                                bLevel = match.group(3) # Basement Level
                                if bLevel.isnumeric():
                                    gName = f"B{bLevel}<sub> - {gName}"
                                if fLevel.isnumeric():
                                    gName = f"F{fLevel}<sub> - {gName}"
                            rName = rName.strip()
                            locations[locType][gID] = f"{rName}/{gName}"
    maniPath = os.path.join(".", "scripts", "constants")
    if not os.path.isdir(maniPath):
        os.makedirs(maniPath)
    with open(os.path.join(maniPath, "roomIDs.lua"), "w+") as roomsFile:
        roomsFile.write("roomIDs = {" + "\n")
        for [locType, locs] in locations.items():
            roomsFile.write(f"  [\"{locType}\"] = " + "{\n")
            for [locID, locName] in natsort.natsorted(locs.items()):
                roomsFile.write(f"    [{locID}] = \"{locName}\"," + "\n")
            roomsFile.write("  }," + "\n")
        roomsFile.write("}" + "\n")
