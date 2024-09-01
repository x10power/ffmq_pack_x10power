import os
import re
import ssl
import urllib.request

from yaml import load, dump
from yaml import CLoader as Loader, CDumper as Dumper

roomYAMLUrl = "https://github.com/wildham0/FFMQRando/raw/master/FFMQRLib/datafiles/rooms.yaml"

context = ssl._create_unverified_context()
roomReq = urllib.request.urlopen(roomYAMLUrl, context=context)
if roomReq:
    roomYAML = load(roomReq.read(), Loader=Loader)
    lines = []
    lines.append("roomIDs = {")
    lines.append("  [\"battlefields\"] = {")
    startedRooms = False
    for room in roomYAML:
        if "game_objects" in room:
            for gObj in room["game_objects"]:
                if "object_id" in gObj:
                    if gObj["object_id"] > 0:
                        if "Battlefield" not in gObj["name"] and not startedRooms:
                            startedRooms = True
                            line = lines[len(lines) - 1]
                            line = line[:len(line) - 1]
                            lines[len(lines) - 1] = line
                            lines.append("  },")
                            lines.append("  [\"rooms\"] = {")
                        msg = ""
                        msg += "    [" + str(gObj["object_id"]) + "]"
                        msg += " = "
                        rName = "@" + room["name"]
                        gName = gObj["name"]
                        if "-" in rName:
                            rName = rName[:rName.find("-") - 1].strip()
                        if "-" in gName:
                            gName = gName[gName.find("-") + 1:].strip()
                        match = re.match(r"^(\@[^\d\@\\]+)([B\d]+)([\dF]+)", rName)
                        if match:
                            rName = match.group(1)  # Room Name
                            # fLevel = match.group(2) # Floor Level
                            # bLevel = match.group(3) # Basement Level
                            # if bLevel.isnumeric():
                            #     gName = f"B{bLevel} - {gName}"
                            # if fLevel.isnumeric():
                            #     gName = f"F{fLevel} - {gName}"
                        rName = rName.strip()
                        msg += "\"" + rName + "/" + gName + "\","
                        lines.append(msg)
    line = lines[len(lines) - 1]
    line = line[:len(line) - 1]
    lines[len(lines) - 1] = line
    lines.append("  }")
    lines.append("}")
    maniPath = os.path.join(".", "scripts", "constants")
    if not os.path.isdir(maniPath):
        os.makedirs(maniPath)
    with open(os.path.join(maniPath, "roomIDs.lua"), "w+") as roomsFile:
        for line in lines:
            roomsFile.write(line + "\n")
