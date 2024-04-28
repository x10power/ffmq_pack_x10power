import pyjson5 as json
from pathlib import Path

uniques = {"refs": []}

def dig_for_children(parent):
    ret = [parent, [None]]
    if isinstance(parent, dict) and \
        "children" in parent:
        ret[0] = parent
        ret[1].append(dig_for_children(parent["children"]))
    if isinstance(parent, list):
        for descendant in parent:
            if "children" in descendant:
                ret[0] = descendant
                ret[1].append(dig_for_children(descendant["children"]))
    return ret

def process_child(parent, child):
    if isinstance(child, list):
        for baby in child:
            process_child(child, baby)
    if child is not None and "sections" in child:
        for section in child["sections"]:
            ref = f"@{child['name']}/{section['name']}"
            if ref in uniques["refs"]:
                print(f"ERROR: Dupe Ref! '{ref}'")
            uniques["refs"].append(ref)
            print(f"  {ref}")

def calc_locrefs():
    # cycle through locations
    for path in sorted(Path("./locations/").glob("**/*.json")):
        print(f"{path}")
        # open locations file
        with path.open("r") as loc_file:
            # load JSON
            loc_json = json.load(loc_file)
            # get first element
            for locations in loc_json:
                # find children
                [parent, descendants] = dig_for_children(locations)
                if "name" in parent:
                    print(f" {parent['name']}")
                if descendants is not None:
                    for descendant in descendants:
                        if descendant is not None:
                            for child in descendant:
                                if child is not None:
                                    if "sections" in child:
                                        process_child(parent, child)
                                    # elif isinstance(child, dict):
                                    #     print(f"NO SECTIONS: {child['name']}")
                                    elif isinstance(child, list):
                                        process_child(parent, child)
                                    else:
                                        pass
                                        # print(child)
            print("")

if __name__ == "__main__":
    calc_locrefs()
