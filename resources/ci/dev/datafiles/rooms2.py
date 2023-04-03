'''
Read Rooms datafile
'''
import json
import os
import re
import ssl
import urllib.request
from yaml import load, dump, CLoader as Loader, CDumper as Dumper

def isnumber(num):
    '''
    Return true if int or isnumeric
    '''
    return isinstance(num, int) or num.isnumeric()

def get_base_dungeon(region):
    '''
    Get base dungeon name
    '''
    for dungeon_name in [
        "Bone Dungeon",
        "Doom Castle",
        "Focus Tower",
        "Giant Tree",
        "Ice Pyramid",
        "Lava Dome",
        "Mac Ship",
        "Macs Ship",
        "Mac's Ship",
        "Mine",
        "Pazuzu",
        "Pazuzu's Tower",
        "Ship Dock",
        "Volcano",
        "Wintry Cave",
        "Wintry Temple",

        "Spencer Cave",
        "Kaidge Temple"
    ]:
        if dungeon_name in region:
            return dungeon_name

def get_floor(location):
    '''
    Return floor number
    '''
    floor_number = ""
    if is_dungeon(location):
        if location.find("-") > -1:
            floor_name = location[:location.find("-")].strip()
            dungeon_name = get_base_dungeon(floor_name)
            floor_number = floor_name.replace(dungeon_name, "").lower().strip()
            print(f"{location}:{floor_name}:{floor_number}")
    return floor_number

def is_dungeon(region):
    '''
    Return true if is dungeon
    '''
    return get_base_dungeon(region) and get_base_dungeon(region) != ""

def is_party(item):
    '''
    Return true if item is party member
    '''
    return "".join(filter(str.isalpha, item.lower())) in [
        "kaeli",
        "phoebe",
        "reuben",
        "tristam"
    ]

def get_base_town(region):
    '''
    Get base town name
    '''
    for town_name in [
        "Foresta",
        "Aquaria",
        "Fireburg",
        "Windia",
        "Otto"
    ]:
        if town_name in region:
            return town_name


def is_town(region):
    '''
    Return true if is town
    '''
    return get_base_town(region) and get_base_town(region) != ""

def get_base_dungeon_or_town(region):
    '''
    Get base dungeon name or town name
    '''
    if is_dungeon(region):
        return get_base_dungeon(region)
    elif is_town(region):
        return get_base_town(region)

def is_dungeon_or_town(region):
    '''
    Return true if is dungeon or is town
    '''
    return is_dungeon(region) or is_town(region)

base_file_path = os.path.join(".","resources","ci","dev","datafiles","output")

rooms_model = {
  "roomsByID": {},
  "idsByName": {},
  "idsByRegion": {},
  "parentByID": {}
}

# get datafile
url = "https://raw.githubusercontent.com/wildham0/FFMQRando/dev/FFMQRLib/datafiles/rooms.yaml"
url = "https://raw.githubusercontent.com/Alchav/FFMQRando/patch-1/FFMQRLib/datafiles/rooms.yaml"
context = ssl._create_unverified_context()
# open datafile
with urllib.request.urlopen(url, context=context) as rooms_req:
    # get yaml
    rooms_yaml = rooms_req.read()
    # convert yaml to data structure
    rooms_data = load(rooms_yaml, Loader=Loader)
    # iterate through rooms
    for roomIDX, room in enumerate(rooms_data):
        if "name" in room:
            room["#room_name"] = room["name"]
        if "id" in room:
            room["#room_id"] = room["id"]
            del room["id"]

        region_name = room["#room_name"]
        mapID = ""
        floor_number = get_floor(region_name)

        if " - " in region_name:
            region_name = region_name[:region_name.find(" - ")]
        if is_dungeon_or_town(region_name):
            region_name = get_base_dungeon_or_town(region_name)
        if region_name is not None:
            mapID = region_name.lower().replace(" ", "-") + "-" + floor_number

        room["#type"] = "Room"

        room["map_locations"] = [
            {
                "map": mapID,
                "x": 0,
                "y": 0
            }
        ]

        if "game_objects" in room:
            if len(room["game_objects"]) > 0:
                room["sections"] = room["game_objects"]
            del room["game_objects"]

        new_links = []
        for link in room["links"]:
            link["access_rules"] = link["access"]
            link["access_rules"] = [",".join(link["access_rules"]).lower()]
            del link["access"]
            if "entrance" in link:
                link["door_id"] = link["entrance"]
                del link["entrance"]
            if "target_room" in link:
                link["to_region"] = link["target_room"]
                if link["to_region"] not in rooms_model["parentByID"]:
                    rooms_model["parentByID"][link["to_region"]] = [room["#room_id"]]
                del link["target_room"]
            if "teleporter" in link:
                del link["teleporter"]
            new_links.append(link)
        del room["links"]
        room["links"] = new_links

        if "sections" in room:
            for sectionIDX, section in enumerate(room["sections"]):
                section["access_rules"] = section["access"]
                for [i, rule] in enumerate(section["access_rules"]):
                    if is_party(rule):
                        item = "".join(filter(str.isalpha, rule))
                        q = "".join(filter(str.isnumeric, rule))
                        rule = f"{item}:{q}"
                        section["access_rules"][i] = rule
                section["access_rules"] = [",".join(section["access_rules"]).lower()]
                del section["access"]

                section["#object_id"] = section["object_id"]
                del section["object_id"]

                if section["type"] == "Box":
                    section["chest_unavailable_img"] = "images/chests/basket_available.png"
                    section["chest_unopened_img"] = "images/chests/basket_available.png"
                    section["chest_opened_img"] = "images/chests/basket_opened.png"
                    section["type"] = "Basket"
                section["item_count"] = 1
                room["sections"][sectionIDX] = section

        rooms_model["roomsByID"][room["#room_id"]] = room
        rooms_model["idsByName"][room["#room_name"]] = room["#room_id"]
        if region_name not in rooms_model["idsByRegion"]:
            rooms_model["idsByRegion"][region_name] = []
        rooms_model["idsByRegion"][region_name].append(room["#room_id"])

if not os.path.isdir(base_file_path):
    os.makedirs(base_file_path)
with open(os.path.join(base_file_path, "rooms_model.json"), "w", encoding="utf-8") as rooms_file:
    json.dump(rooms_model, rooms_file, indent=2)

new_rooms = {}

for region_name, roomIDs in rooms_model["idsByRegion"].items():
    new_room = {
        "name": region_name,
        "parent": "",
        "#parent_id": "",
        "#type": "Region",
        "#region_id": rooms_model["idsByName"][region_name] if region_name in rooms_model["idsByName"] else ""
    }

    children = []
    parentParentID = -1
    for roomIDX, roomID in enumerate(roomIDs):
        child = rooms_model["roomsByID"][roomID]
        if "links" in child:
            for linkIDX, link in enumerate(child["links"]):
                if "to_region" in link:
                    if linkIDX == 0:
                        parentID = link["to_region"]
                        if (roomIDX == 0) or ((roomIDX == 1) and ("Ice Pyramid" in child["name"])):
                            parentParentID = parentID
                        child["parent"] = parentID
                        child["#parent_name"] = rooms_model["roomsByID"][parentID]["name"]
                    if link["to_region"] in rooms_model["roomsByID"]:
                        child["links"][linkIDX]["#to_region_name"] = rooms_model["roomsByID"][link["to_region"]]["#room_name"]
        children.append(child)
    new_room["children"] = [
        {"name": "Overworld", "children": children},
        {"name": "Underworld", "children": children}
    ]

    if parentParentID != -1:
        parent_name = rooms_model["roomsByID"][parentParentID]["name"]
        print(f"SETTING PARENT: {parent_name} ({parentParentID}) for {region_name} ({new_room['#region_id']})")
        new_room["parent"] = parent_name
        new_room["#parent_id"] = parentParentID
    else:
        print(f"NOT Setting Parent: {region_name}: {new_room['#region_id']}")

    if region_name:
        new_rooms[region_name] = new_room
        filepath = os.path.join(base_file_path, region_name + ".json")
        with open(filepath, "w", encoding="utf-8") as region_file:
            json.dump(new_rooms[region_name], region_file, indent=2)
