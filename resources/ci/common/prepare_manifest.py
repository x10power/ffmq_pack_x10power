import common
import json
import os                 # for env vars
from shutil import copy   # file manipulation

def prepare_manifest():
  env = common.prepare_env()

  APPVERSION = ""

  # set tag to app_version.txt
  with open(os.path.join("..", "build", "app_version.txt"), "r") as f:
      APPVERSION = f.readlines()[0]

  with open(os.path.join("manifest.json"), mode="r+", encoding="utf-8") as manifestFile:
      manifestJSON = json.load(manifestFile)
      if "variants" in manifestJSON:
          flags = []
          for variant in manifestJSON["variants"]:
              if "flags" in variant:
                  flags.append(*variant["flags"])
          flags = set(flags)
          manifestJSON["flags"] = sorted(list(flags))

      if APPVERSION != "":
          manifestJSON["package_version"] = APPVERSION

      manifestFile.seek(0)
      manifestFile.write(json.dumps(manifestJSON, indent=2))
      manifestFile.truncate()

def main():
  prepare_manifest()

if __name__ == "__main__":
  main()
else:
  raise AssertionError("Script improperly used as import!")
