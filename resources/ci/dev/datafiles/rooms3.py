'''
Read Rooms datafile
'''
import json
import os
import re
import ssl
import urllib.request
from yaml import load, dump, CLoader as Loader, CDumper as Dumper

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

def get_base_dungeon(region):
    '''
    Get base dungeon name
    '''
    for [element, dungeon_names] in {
        "earth": [
            "Bone Dungeon"
        ],
        "water": [
            "Wintry Cave",
            "Fall Basin",
            "Falls Basin",
            "Ice Pyramid"
        ],
        "fire": [
            "Mine",
            "Volcano",
            "Lava Dome"
        ],
        "wind": [
            "Spencer Cave",
            "Mac Ship",
            "Macs Ship",
            "Mac's Ship",
            "Giant Tree",
            "Mount Gale",
            "Pazuzu",
            "Pazuzu Tower",
            "Pazuzu's Tower"
        ],
        "center": [
            "Focus Tower",
            "Ship Dock",
            "Doom Castle"
        ]
    }.items():
        for dungeon_name in dungeon_names:
            if dungeon_name in region:
                return [element, dungeon_name]

def get_floor(location):
    '''
    Return floor number
    '''
    floor_number = ""
    if is_dungeon(location):
        floor_name = location
        if location.find("-") > -1:
            floor_name = location[:location.find("-")].strip()

        # Floor number
        floor_number = ""
        matches = re.findall(r"(B?)([\d])(F?)", floor_name)
        if len(matches) == 1:
            floor_number = "".join(matches[0])
        # print(f"{location}:{floor_name}:{floor_number}")
    return floor_number

def is_dungeon(region):
    '''
    Return true if is dungeon
    '''
    return get_base_dungeon(region) and get_base_dungeon(region)[1] != ""

def get_base_town(region):
    '''
    Get base town name
    '''
    for [element, town_names] in {
        "earth": [
            "Level Forest",
            "Foresta",
            "Sand Temple"
        ],
        "water": [
            "Libra Temple",
            "Aquaria",
            "Life Temple",
            "Wintry Temple",
            "Spencer's Place"
        ],
        "fire": [
            "Fireburg",
            "Sealed Temple"
        ],
        "wind": [
            "Rope Bridge",
            "Alive Forest",
            "Kaidge Temple",
            "Light Temple",
            "Windia",
            "Windhole Temple",
            "Ship Dock",
            "Otto"
        ]
    }.items():
        for town_name in town_names:
            if town_name in region:
                return [element, town_name]

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

base_file_path = os.path.join(
    ".",
    "resources",
    "ci",
    "dev",
    "datafiles",
    "output"
)

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
        # save room name
        region_name = ""
        if "name" in room:
            region_name = room["name"]
            room["#room_name"] = region_name
            room["#region_name"] = region_name
            if is_dungeon(region_name):
                floor_number = get_floor(region_name)
                if floor_number == "":
                    if "game_objects" in room:
                        for game_object in room["game_objects"]:
                            if floor_number == "":
                                floor_number = get_floor(game_object["name"])
                [element, region_name] = get_base_dungeon(region_name)
                room["#region_name"] = region_name
                if floor_number != "":
                    room["#floor_id"] = floor_number
                    room["#room_name"] = room["#room_name"].replace(f"{region_name} {floor_number} - ", "")
                    room["#map_id"] = f"{region_name.replace(' ', '-')}-{floor_number}".lower()
            room["#room_name"] = room["#room_name"].replace(f"{region_name} - ", "")
        # save roomID
        if "id" in room:
            # copy and delete roomID
            room["#room_id"] = room["id"]
            del room["id"]
        # set type
        room["#type"] = "Room"

        # cycle through game objects
        # save as sections
        if "game_objects" in room:
            if len(room["game_objects"]) > 0:
                room["sections"] = room["game_objects"]
            del room["game_objects"]

        # cycle through links
        new_links = []
        for link in room["links"]:
            # process access rules
            link["access_rules"] = [",".join(link["access"]).lower()]
            del link["access"]

            # process door ID
            if "entrance" in link:
                link["door_id"] = link["entrance"]
                del link["entrance"]

            # process target room
            if "target_room" in link:
                link["to_region"] = link["target_room"]
                if link["to_region"] not in rooms_model["parentByID"]:
                    rooms_model["parentByID"][link["to_region"]] = [room["#room_id"]]
                del link["target_room"]

            # delete teleporter information
            if "teleporter" in link:
                del link["teleporter"]
        del room["links"]
        room["links"] = new_links

        # cycle through sections
        if "sections" in room:
            for [sectionIDX, section] in enumerate(room["sections"]):
                check_name = room["#region_name"]
                if "#floor_id" in room:
                    check_name = f"{room['#region_name']} {room['#floor_id']}"
                if check_name in section["name"]:
                    section["name"] = section["name"].replace(f"{check_name} - ", "")
                # copy access rules
                section["access_rules"] = section["access"]
                # cycle through access rules
                for [i, rule] in enumerate(section["access_rules"]):
                    # fix party rules
                    if is_party(rule):
                        item = "".join(filter(str.isalpha, rule))
                        q = "".join(filter(str.isnumeric, rule))
                        rule = f"{item}:{q}"
                        section["access_rules"][i] = rule
                section["access_rules"] = [",".join(section["access_rules"]).lower()]
                # delete old access
                del section["access"]

                # copy & delete object ID
                section["#object_id"] = section["object_id"]
                del section["object_id"]

                # if it's a box
                if section["type"] == "Box":
                    section["chest_unavailable_img"] = "images/chests/basket_available.png"
                    section["chest_unopened_img"] = "images/chests/basket_available.png"
                    section["chest_opened_img"] = "images/chests/basket_opened.png"
                    section["type"] = "Basket"
                # if it's an NPC
                if section["type"] == "NPC":
                    section["chest_unavailable_img"] = f"images/party/{section['name'].lower()}.gif"
                    section["chest_unopened_img"] = f"images/party/{section['name'].lower()}.gif"
                    section["chest_opened_img"] = f"images/party/{section['name'].lower()}.gif"

                # set it to show
                section["item_count"] = 1
                room["sections"][sectionIDX] = section

        # save to rooms model
        # save by roomID
        # save by roomName
        rooms_model["roomsByID"][room["#room_id"]] = room
        rooms_model["idsByName"][room["#room_name"]] = room["#room_id"]

        # save by region
        if is_dungeon_or_town(region_name):
            [element, region_name] = get_base_dungeon_or_town(region_name)
        if region_name not in rooms_model["idsByRegion"]:
            rooms_model["idsByRegion"][region_name] = []
        rooms_model["idsByRegion"][region_name].append(room["#room_id"])

if not os.path.isdir(base_file_path):
    os.makedirs(base_file_path)
with open(os.path.join(base_file_path, "rooms_model.json"), "w", encoding="utf-8") as rooms_file:
    json.dump(rooms_model, rooms_file, indent=2)

new_rooms = {}
max_sections = 0

for [region_name, roomIDs] in rooms_model["idsByRegion"].items():
    new_room = {
        "name": region_name,
        "parent": "",
        "#parent_id": "",
        "#type": "Region",
        "#region_id": rooms_model["idsByName"][region_name] if region_name in rooms_model["idsByName"] else ""
    }

    children = [
        {
          "name": f"{region_name} Overworld",
          "map_location": [
              {
                  "map": "",
                  "x": 0,
                  "y": 0
              }
          ],
          "sections": []
        }
    ]
    if is_dungeon_or_town(region_name):
        children.append(
            {
              "name": f"{region_name} Underworld",
              "children": []
            }
        )

    floors = []
    floor = []
    flats = []
    flat = []
    prevFloorID = ""
    for [roomIDX, roomID] in enumerate(roomIDs):
        child = rooms_model["roomsByID"][roomID]
        has_floors = ("#floor_id" in child) and (child["#floor_id"] != "")

        if has_floors and ("sections" in child):
            if len(flat) == 0:
                floorID = child["#floor_id"]
                flat = [
                    {
                        "name": f"Floor {floorID} Baskets",
                        "access_rules": {},
                        "item_count": 0
                    },
                    {
                        "name": f"Floor {floorID} Chests",
                        "access_rules": {},
                        "item_count": 0
                    },
                    {
                        "name": f"Floor {floorID} NPCs",
                        "access_rules": {},
                        "item_count": 0
                    }
                ]

            if len(child["sections"]) > max_sections:
                max_sections = len(child["sections"])
            for section in child["sections"]:
                sectionTypes = [ "Basket", "Chest", "NPC" ]
                if section["type"] in sectionTypes:
                    flat[sectionTypes.index(section["type"])]["item_count"] += section["item_count"]
                    for access in section["access_rules"]:
                        if access not in flat[sectionTypes.index(section["type"])]["access_rules"]:
                            flat[sectionTypes.index(section["type"])]["access_rules"][access] = 0
                        flat[sectionTypes.index(section["type"])]["access_rules"][access] += 1

        if "links" in child:
            for [linkIDX, link] in enumerate(child["links"]):
                if "to_region" in link:
                    if linkIDX == 0:
                        parentID = link["to_region"]
                        if (roomIDX == 0) or ((roomIDX == 1) and ("Ice Pyramid" in child["name"])):
                            parentParentID = parentID
                        child["parent"] = parentID
                        child["#parent_name"] = rooms_model["roomsByID"][parentID]["name"]
                    if link["to_region"] in rooms_model["roomsByID"]:
                        child["links"][linkIDX]["#to_region_name"] = rooms_model["roomsByID"][link["to_region"]]["#room_name"]
        if has_floors:
            floorID = child["#floor_id"]
            if prevFloorID != "" and prevFloorID != floorID:
                floors.append(
                    {
                        "name": f"Floor {prevFloorID}",
                        "children": floor
                    }
                )

                newFlat = []
                for section in flat:
                    if section["item_count"] > 0:
                        newFlat.append(section)
                flat = newFlat

                if len(flats) == 0:
                    flats = flat
                else:
                    flats = [*flats, *flat]
                floor = []
                flat = [
                    {
                        "name": f"Floor {floorID} Baskets",
                        "access_rules": {},
                        "item_count": 0
                    },
                    {
                        "name": f"Floor {floorID} Chests",
                        "access_rules": {},
                        "item_count": 0
                    },
                    {
                        "name": f"Floor {floorID} NPCs",
                        "access_rules": {},
                        "item_count": 0
                    }
                ]
            prevFloorID = child["#floor_id"]
            floor.append(child)

    if len(flats) > 0:
        newFlat = []
        for section in flat:
            if section["item_count"] > 0:
                newFlat.append(section)
        flat = newFlat
        flats = [*flats, *flat]
        coords = [0,0]
        for flat in flats:
            for [access, q] in flat["access_rules"].items():
                flatName = f"{flat['name']}"
                if access != "":
                    flatName += f" ({access})"
                floorID = re.match(r"Floor ([^\s]+)", flatName).group(1)
                children[0]["sections"].append(
                    {
                        "name": flatName,
                        "map_locations":[
                            {
                                "map": f"{region_name.replace(' ', '-').lower()}-{floorID.lower()}",
                                "x": coords[0],
                                "y": coords[1]
                            }
                        ],
                        "access_rules": [access],
                        "item_count": q
                    }
                )
                coords[0] += 16
        # children[0]["sections"] = flats
    if len(floors) > 0:
        floors.append(
            {
                "name": f"Floor {prevFloorID}",
                "children": floor
            }
        )
        if len(children) > 1:
            children[1]["children"] = floors

    new_room["children"] = children

    if region_name:
        new_rooms[region_name] = new_room
        filename = region_name.replace(" ", "-").replace("'", "").lower()
        element = ""
        if get_base_dungeon_or_town(region_name):
            [element, _] = get_base_dungeon_or_town(region_name)
        filepath = base_file_path
        if element and (element != ""):
            filepath = os.path.join(filepath, element)
        if not os.path.isdir(filepath):
            os.makedirs(filepath)
        with open(os.path.join(filepath, f"{filename}.json"), "w", encoding="utf-8") as region_file:
            json.dump(new_rooms[region_name], region_file, indent=2)

print(max_sections)
