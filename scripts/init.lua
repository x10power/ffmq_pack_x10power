-- Version
ScriptHost:LoadScript("scripts/ver.lua")

-- Settings
ScriptHost:LoadScript("scripts/settings/settings.lua")

-- Helpers
ScriptHost:LoadScript("scripts/items/helpers.lua")

local variant = Tracker.ActiveVariantUID
if variant == "" then
  variant = "items_only"
end

-- Auto-Tracking
if (string.find(variant, "items_only")) then
  print("Loading Auto-Tracking: " .. variant)
  ScriptHost:LoadScript("scripts/tracking/autotracking.lua")
end
if (string.find(variant, "shard_hunt")) then
  print("Loading Auto-Tracking: " .. variant)
  ScriptHost:LoadScript("scripts/tracking/autotracking-sh.lua")
end

-- Items
print("Loading Items")
dir = "items"
items = {
  "armor",
  "counters",
  "crystals",
  "magics",
  "party",
  "storymarkers",
  "weapons",
  "toggles"
}
for _, itemCat in ipairs(items) do
  Tracker:AddItems(dir .. "/" .. itemCat .. ".json")
end
print("")

-- Grids
print("Loading Grids")
dir = "layouts/grids"
grids = {
  "magics/blackmagics",
  "magics/whitemagics",
  "magics/wizardmagics",
  "armors",
  "coins",
  "counters",
  "crests",
  "crystals",
  "keyitems",
  "magics",
  "party",
  "storymarkers",
  "weapons",
  "grids"
}
for _, gridCat in ipairs(grids) do
  Tracker:AddLayouts(dir .. "/" .. gridCat .. ".json")
end
print("")

if string.find(variant, "map") then
  print("Map Variant; load map stuff")
  -- World Map
  Tracker:AddMaps("maps/maps.json")

  -- Dungeon Maps
  dungeons = {
    "bonedungeon",
    "doomcastle",
    "gianttree",
    "icepyramid",
    "lavadome",
    "macship",
    "pazuzutower"
  }
  for _, dungCat in ipairs(dungeons) do
    Tracker:AddMaps("maps/dungeons/" .. dungCat .. ".json")
  end

  -- Map Layouts
  Tracker:AddLayouts("layouts/maps/world.json")

  -- Locations
  locations = {
    -- World
    "world",
    -- Battlefields
    -- "battlefields/main",
    -- Center
    "center/focustower",
    "center/doom-castle",
    -- Earth
    "earth/main",
    "earth/foresta",
    "earth/bonedungeon",
    -- Fire
    "fire/main",
    "fire/fireburg",
    "fire/lava-dome",
    -- Water
    "water/main",
    "water/aquaria",
    "water/icepyramid",
    -- Wind
    "wind/main",
    "wind/windia",
    "wind/giant-tree",
    "wind/pazuru-tower",
    "wind/mac-ship"
  }
  for _, locCat in ipairs(locations) do
    Tracker:AddLocations("locations/" .. locCat .. ".json")
  end
  print("")
else
  -- Legacy
  print("Satisfy Legacy Loads")
  Tracker:AddMaps("maps/maps.json")
  Tracker:AddLocations("locations/world.json")
  print("")
end

-- Variant Overrides
if variant ~= "items_only" then
  print("Loading Variant")
  -- Layout Overrides
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker.json")    -- Main Tracker
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/broadcast.json")  -- Broadcast View
  print("")
else
  print("Not a Variant; load default stuff")
  -- Layout Defaults
  Tracker:AddLayouts("layouts/tracker.json")
  Tracker:AddLayouts("layouts/broadcast.json")
  print("")
end
