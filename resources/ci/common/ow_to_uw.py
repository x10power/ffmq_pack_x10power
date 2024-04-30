import json
from pathlib import Path

for path in sorted(Path("./locations/overworld/").glob("**/*.json")):
    if "battlefield" not in str(path) and "main" not in str(path):
        with path.open("r") as room_file:
            print(path)
            room_json = json.load(room_file)
            new_region = {}
            for region in room_json:
                region_name = region["name"]
                new_region = {
                    "name": region_name + " Underworld",
                    "parent": region_name + " Overworld"
                }
                for chest_img in [
                    "chest_unavailable_img",
                    "chest_unopened_img",
                    "chest_opened_img"
                ]:
                    if chest_img in region:
                        new_region[chest_img] = region[chest_img]
                new_region["children"] = []
                group_name = ""
                floor_group = ""
                x = 0
                if "children" in region:
                    for section in region["children"][0]["sections"]:
                        hosted = "hosted_item" in section
                        has_count = "item_count" in section
                        pseudo_count = "#item_count" in section
                        section_name = section["name"]

                        floor_id = ""

                        if " - " in section_name:
                            floor_id = section_name[:section_name.find(" - ")]
                            section_name = section_name[section_name.find(" - ")+3:]
                            if floor_id != floor_group:
                                floor_group = floor_id
                                x = 0
                        map_id = region_name. \
                            lower(). \
                            replace("'s",""). \
                            replace(" ","-") + "-" + floor_id.lower()
                        ref = f"@{region_name} Overworld/{section['name']}"
                        if has_count and section["item_count"] != 1:
                            group_name = section["name"]
                            has_count = False
                        if pseudo_count:
                            ref = f"@{region_name} Overworld/{group_name}"
                            has_count = True
                            del section["#item_count"]
                        if hosted or has_count:
                            section["name"] = section_name
                            section["access_rules"] = [ref]
                            if "item_count" in section:
                                del section["item_count"]
                            if floor_id != "":
                                if "Chest" in section_name:
                                    for [chest_key,chest_img] in {
                                        "unavailable":"available",
                                        "unopened":"available",
                                        "opened":"opened"
                                    }.items():
                                        section["chest_" + chest_key + "_img"] = f"images/chests/{chest_img}.png"

                                section["sections"] = [{"name":"Item","item_count":1}]
                                section["map_locations"] = [{"map":map_id,"x":x,"y":0}]
                                section["#floor"] = f"{region_name} Floor {floor_id.upper()}"
                            x += 16
                            new_region["children"].append(section)
            new_region = [new_region]
            if len(new_region[0]["children"]):
                with open(str(path).replace("overworld","underworld"), "w+") as new_file:
                    json.dump(new_region, new_file, indent=2)
