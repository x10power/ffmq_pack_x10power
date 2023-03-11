'''
Read Rooms datafile
'''
import json
import os
import re
import ssl
import urllib.request
from yaml import load, dump, CLoader as Loader, CDumper as Dumper

groups = {
  "Alive Forest": [],
  "Aquaria": [],
  "Bone Dungeon": [],
  "Doom Castle": [],
  "Fall Basin": [],
  "Fireburg": [],
  "Focus Tower": [],
  "Foresta": [],
  "Giant Tree": [],
  "Ice Pyramid": [],
  "Kaidge Temple": [],
  "Lava Dome": [],
  "Level Forest": [],
  "Libra Temple": [],
  "Life Temple": [],
  "Light Temple": [],
  "Mac Ship": [],
  "Mine": [],
  "Mount Gale": [],
  "Otto's": [],
  "Pazuzu": [],
  "Rope Bridge": [],
  "Sand Temple": [],
  "Sealed Temple": [],
  "Ship Dock": [],
  "Spencer Cave": [],
  "Volcano": [],
  "Windhole Temple": [],
  "Windia": [],
  "Wintry Cave": [],
  "Wintry Temple": [],
  "Unsorted": []
}

# get datafile
url = "https://raw.githubusercontent.com/wildham0/FFMQRando/dev/FFMQRLib/datafiles/rooms.yaml"
context = ssl._create_unverified_context()
# open datafile
with urllib.request.urlopen(url, context=context) as rooms_req:
    # get yaml
    rooms_yaml = rooms_req.read()
    # convert yaml to data structure
    rooms_data = load(rooms_yaml, Loader=Loader)
    # iterate through rooms
    for _, room in enumerate(rooms_data):
        # if this room has objects
        if len(room["game_objects"]):
            # assume not a dungeon
            # get ID
            # get name
            is_dungeon = False
            room_id = room["id"]
            room_name = room["name"]

            # build room object
            room_data = {
                "id": room_id,
                "name": room_name,
                "type": "Room",
                "children": []
            }
            # print(f"{room_id}: {room_name}")

            # get zone name
            room_name_parts = room_name.split(" ")
            room_tag = room_name_parts[0]
            if len(room_name_parts) > 1:
                room_tag = room_name_parts[0] + " " + room_name_parts[1]
            if room_tag not in groups:
                room_tag = room_name_parts[0]
                if room_tag not in groups:
                    room_tag = "Unsorted"

            # build region object
            # include Overworld
            region_data = {
                "name": room_tag,
                "parent": "",
                "type": "Region",
                "access_rules": [],
                "children": [
                    {
                        "name": (f"{room_tag} Overworld"),
                        "children": []
                    }
                ]
            }

            # is this a dungeon?
            if room_tag in [
                "Bone Dungeon",
                "Doom Castle"
                "Focus Tower",
                "Giant Tree",
                "Ice Pyramid",
                "Lava Dome",
                "Mac Ship",
                "Macs Ship",
                "Mac's Ship",
                "Pazuzu's Tower",
                "Ship Dock",
                "Wintry Cave",
                "Wintry Temple"
            ]:
                # prepare dungeon object
                # add Underworld
                is_dungeon = True
                region_data["type"] = "Dungeon"
                region_data["children"][0]["children"].append(
                    {
                        "name": (f"{room_tag}"),
                        "access_rules": [],
                        "map_locations": [
                            {
                                "map": "drained-world",
                                "x": 0,
                                "y": 0
                            },
                            {
                                "map": "restored-world",
                                "x": 0,
                                "y": 0
                            }
                        ],
                        "sections": []
                    }
                )
                region_data["children"].append(
                    {
                        "name": (f"{room_tag} Underworld"),
                        "children": []
                    }
                )
            # print(region_data)

            # cycle through game objects
            for obj in room["game_objects"]:
                new_access = []
                # convert [item][num] to [item]:[num]
                for expr in obj["access"]:
                    expr = expr.lower()
                    item = "".join(filter(str.isalpha, expr))
                    q = "".join(filter(str.isdigit, expr))
                    if q:
                        expr = (f"{item}:{q}")
                    new_access.append(expr)
                # create room object object
                room_obj = {
                    "name": obj["name"],
                    "type": obj["type"],
                    "access_rules": [
                        ",".join(new_access).lower()
                    ],
                    "map_locations": []
                }
                if is_dungeon:
                    room_obj["name"] = (f"{room_name} - {obj['name']}")
                    map_floor = region_data["name"].lower().replace(" ", "-")
                    pattern = r"(?:[\s])([B\d|\dF]{2})(?:[\s])"
                    match = re.search(pattern, " " + room_name + " ")
                    if match:
                        map_floor = (f"{map_floor}-{match.group(1).lower()}")
                    else:
                        print(f"{room_name} - {map_floor}")
                    room_obj["map_locations"].append(
                        {
                            "map": map_floor,
                            "x": 0,
                            "y": 0
                        }
                    )
                else:
                    room_obj["map_locations"] = [
                        {
                            "map": "drained-world",
                            "x": 0,
                            "y": 0
                        },
                        {
                            "map": "restored-world",
                            "x": 0,
                            "y": 0
                        }
                    ]
                if room_obj["type"] == "Box":
                    room_obj["chest_unavailable_img"] = "images/chests/basket_available.png"
                    room_obj["chest_unopened_img"] = "images/chests/basket_available.png"
                    room_obj["chest_opened_img"] = "images/chests/basket_opened.png"
                room_obj["sections"] = [
                    {
                        "name": obj["type"],
                        "item_count": 1
                    }
                ]

                # add region if it doesn't exist yet
                if room_tag in groups and len(groups[room_tag]) == 0:
                    groups[room_tag] = region_data
                # if dungeon
                if is_dungeon:
                    #  add underworld listing
                    #  which is full-size per floor
                    if " - " in room_obj["name"]:
                        room_obj["name"] = room_obj["name"][room_obj["name"].rfind(" - ") + len(" - "):]
                    groups[room_tag]["children"][1]["children"].append(room_obj)
                    # add overworld listing,
                    #  which is shorthand name, small-size at root
                    groups[room_tag]["children"][0]["children"][0]["sections"].append(room_obj)

            #     if is_dungeon:
            #         region_data["children"][0]["children"].append(room_obj)
            #     room_data["children"].append(room_obj)
            #     msg = (f"  {obj['type']}: {obj['name']}")
            #     if len(obj["access"]):
            #         msg = (f"{msg}: {obj['access']}")
            #     print(msg)
            # if len(groups[room_tag]) < 1 and len(region_data["children"]) > 1:
            #     region_data["children"][1]["children"].append(room_data)
            #     groups[room_tag].append(region_data)

# for room in groups["Unsorted"]:
#     print(room["name"])

print(json.dumps(groups["Bone Dungeon"],indent=2))
