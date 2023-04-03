-- Version
ScriptHost:LoadScript("scripts/ver.lua")

-- Settings
ScriptHost:LoadScript("scripts/settings/settings.lua")

-- Helpers
ScriptHost:LoadScript("scripts/items/helpers.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic.lua")

local variant = Tracker.ActiveVariantUID
if variant == "" then
  variant = "items_only"
end

-- Auto-Tracking
print("Loading Auto-Tracking: " .. variant)
ScriptHost:LoadScript("scripts/tracking/autotracking.lua")

-- Items
print("Loading Items")
dir = "items"
items = {
  "armor",
  "counters",
  "crystals",
  "magics",
  "party",
  "settings",
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
  "non-progressives/armors",
  "non-progressives/keyitems",
  "non-progressives/magics",
  "non-progressives/weapons",
  "non-progressives/grids",
  "binary/armors",
  "binary/keyitems",
  "binary/magics",
  "binary/weapons",
  "binary/grids",
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
    "wintrycave",
    "icepyramid",
    "lavadome",
    "doomcastle",
    "gianttree",
    "macship",
    "pazuzutower"
  }
  for _, dungCat in ipairs(dungeons) do
    Tracker:AddMaps("maps/dungeons/" .. dungCat .. ".json")
  end

  -- Map Layouts
  -- Dungeon Maps
  dungMaps = {
    "earth/bonedungeon",
    "earth/earth",
    "water/wintrycave",
    "water/icepyramid",
    "water/water",
    "fire/lavadome",
    "fire/fire",
    "wind/gianttree",
    "wind/pazuzutower",
    "wind/wind",
    "focustower/doomcastle",
    "focustower/macship",
    "focustower/focustower"
  }
  for _, dungMap in pairs(dungMaps) do
    Tracker:AddLayouts("layouts/maps/dungeons/" .. dungMap .. ".json")
  end
  Tracker:AddLayouts("layouts/maps/world.json")

  -- Locations
  locations = {
    -- World
    "world",
    -- Center
    "center/focus-tower",
    "center/doom-castle",
    -- Earth
    "earth/main",
    "earth/foresta",
    "earth/bone-dungeon",
    -- Fire
    "fire/main",
    "fire/fireburg",
    "fire/lava-dome",
    -- Water
    "water/main",
    "water/aquaria",
    "water/wintry-cave",
    "water/ice-pyramid",
    -- Wind
    "wind/main",
    "wind/windia",
    "wind/giant-tree",
    "wind/pazuzu-tower",
    "wind/mac-ship",
    -- Battlefields
    "battlefields/main"
  }
  for _, locCat in ipairs(locations) do
    Tracker:AddLocations("locations/" .. locCat .. ".json")
    Tracker:AddLocations("resources/ci/dev/datafiles/output/" .. locCat .. ".json")
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
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker-capture.json")     -- Capture Grid
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker-horizontal.json")  -- Horizontal Tracker
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker-vertical.json")    -- Vertical Tracker
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker.json")             -- Main Tracker
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/broadcast.json")           -- Broadcast View
  print("")
else
  print("Not a Variant; load default stuff")
  -- Layout Defaults
  Tracker:AddLayouts("layouts/tracker-capture.json")    -- Capture Grid
  Tracker:AddLayouts("layouts/tracker-horizontal.json") -- Horizontal Tracker
  Tracker:AddLayouts("layouts/tracker-vertical.json")   -- Vertical Tracker
  Tracker:AddLayouts("layouts/tracker.json")            -- Main Tracker
  Tracker:AddLayouts("layouts/broadcast.json")          -- Broadcast View
  print("")
end
