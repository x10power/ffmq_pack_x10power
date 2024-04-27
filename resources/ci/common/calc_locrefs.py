import pyjson5 as json
from pathlib import Path

uniques = {"refs": []}

def dig_for_children(parent):
    ret = parent
    if isinstance(parent, dict) and \
        "children" in parent:
        ret = parent
        return dig_for_children(parent["children"])
    if isinstance(parent, list) and \
        isinstance(parent[0], dict) and \
        "children" in parent[0]:
        ret = parent[0]
        return dig_for_children(parent[0]["children"])
    return ret

def calc_locrefs():
    # cycle through locations
    for path in sorted(Path("./locations/").glob("**/*.json")):
        print(path)
        # open locations file
        with path.open("r") as loc_file:
            # load JSON
            loc_json = json.load(loc_file)
            # get first element
            locations = loc_json[0]
            print(f" {locations['name']}")
            # find children
            children = (dig_for_children(locations))
            for child in children:
                if "sections" in child:
                    for section in child["sections"]:
                        ref = f"{child['name']}/{section['name']}"
                        if ref in uniques["refs"]:
                            print(f"ERROR: Dupe Ref! '{ref}'")
                        uniques["refs"].append(ref)
                        print(f"  {ref}")
                elif isinstance(child, dict):
                    print(f"NO SECTIONS: {child['name']}")
        print("")

if __name__ == "__main__":
    calc_locrefs()
