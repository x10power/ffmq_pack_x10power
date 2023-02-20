# pylint: disable=invalid-name, no-member, protected-access
'''
Validate JSON against provided schema
'''
import os
import json
import ssl
import urllib.request
from pathlib import Path
import pyjson5
from jsonschema import validate, RefResolver

def check_files(dirs):
    '''
    Check files recursively
    '''
    # cycle through dirs
    for resrcDir in dirs:
        # cycle through this dir
        jsonType = ""
        for jsonTypeCheck in ["items", "layouts", "locations"]:
            if jsonTypeCheck in resrcDir:
                jsonType = jsonTypeCheck
        if "maps" in resrcDir:
            continue
        if jsonType != "":
            for r, _, f in os.walk(resrcDir):
                for filename in f:
                    if ".json" in filename:
                        # open file
                        filePath = os.path.join(r, filename)
                        print("  " + filePath)
                        with open(filePath, "r", encoding="utf-8") as jsonFile:
                            fileJSON = pyjson5.decode_io(jsonFile)
                            validate(
                                instance=fileJSON,
                                schema=schemas["emo"][jsonType],
                                resolver=RefResolver(
                                    base_uri=schemaURI,
                                    referrer=schemas["emo"][jsonType]
                                )
                            )
        else:
            print("TYPE NOT FOUND: " + resrcDir)
            print()

schemas = {}
schemaSrcs = [
  "https://emotracker.net/developers/schemas/items.json",
  # "https://emotracker.net/developers/schemas/layouts.json",
  "https://emotracker.net/developers/schemas/locations.json"
]

schemaDir = os.path.join(".", "schema")
print("DOWNLOAD SCHEMAS")
if not os.path.isdir(schemaDir):
    os.makedirs(schemaDir)
for url in schemaSrcs:
    context = ssl._create_unverified_context()
    with urllib.request.urlopen(url, context=context) as schema_req:
        schema_data = schema_req.read()
        if not os.path.isfile(os.path.join(schemaDir, os.path.basename(url))):
            with open(os.path.join(schemaDir, os.path.basename(url)), "wb") as schema_file:
                schema_file.write(schema_data)

print("LOAD SCHEMAS")
schemaAbsPath = os.path.abspath(schemaDir)
schemaURI = Path(schemaAbsPath).as_uri() + "/"
for schemaFileName in os.listdir(schemaDir):
    if os.path.isfile(os.path.join(schemaDir, schemaFileName)):
        with open(
            os.path.join(
                schemaDir,
                schemaFileName
            ),
            "r",
            encoding="utf-8"
        ) as schemaFile:
            gameKey = "emo"
            schemaKey = schemaFileName.replace(".json", "")
            if gameKey not in schemas:
                schemas[gameKey] = {}
            schemas[gameKey][schemaKey] = json.load(schemaFile)

print("VALIDATE")
srcs = {
    "ffmq": {
        "packUID": "ffmq_pack_x10power",
        "variants": [
            "items_only",
            "shard_hunt",
            "standard_map"
        ]
    }
}

for [gameID, packData] in srcs.items():
    packUID = packData["packUID"]
    variants = packData["variants"]
    packRoot = os.path.join(".")
    if os.path.isdir(packRoot):
        print(gameID, packUID)
        layoutKeyMap = {}
        resrcDirs = [
            os.path.join(packRoot, "items"),
            os.path.join(packRoot, "layouts"),
            os.path.join(packRoot, "locations"),
            os.path.join(packRoot, "maps")
        ]
        # print(resrcDirs)
        check_files(resrcDirs)

        for variant in variants:
            layoutKeyMap = {}
            resrcDirs = {
                os.path.join(packRoot, "variants", variant, "items"),
                os.path.join(packRoot, "variants", variant, "layouts"),
                os.path.join(packRoot, "variants", variant, "locations"),
                os.path.join(packRoot, "variants", variant, "maps")
            }
            # print(resrcDirs)
            check_files(resrcDirs)
