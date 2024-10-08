-- Version
ScriptHost:LoadScript("scripts/ver.lua")

-- Settings
ScriptHost:LoadScript("scripts/settings/settings.lua")

-- Helpers
ScriptHost:LoadScript("scripts/items/helpers.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")

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
  "battlefields",
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
Tracker:AddLayouts("layouts/settings.json")
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
    "settlements/foresta",

    "settlements/aquaria",

    "settlements/fireburg",

    "settlements/aliveforest",
    "settlements/kaidgetemple",
    "settlements/ropebridge",
    "settlements/windia",

    "dungeons/levelforest",
    "dungeons/bonedungeon",

    "dungeons/wintrycave",
    "dungeons/fallsbasin",
    "dungeons/icepyramid",

    "dungeons/mine",
    "dungeons/volcano",
    "dungeons/lavadome",

    "dungeons/doomcastle",

    "dungeons/gianttree",
    "dungeons/mountgale",
    "dungeons/macship",
    "dungeons/pazuzutower"
  }
  for _, dungCat in ipairs(dungeons) do
    Tracker:AddMaps("maps/" .. dungCat .. ".json")
  end

  -- Map Layouts
  -- Dungeon Maps
  dungMaps = {
    "settlements/earth/foresta",
    "settlements/earth/earth",

    "settlements/water/aquaria",
    "settlements/water/water",

    "settlements/fire/fireburg",
    "settlements/fire/fire",

    "settlements/wind/aliveforest",
    "settlements/wind/kaidgetemple",
    "settlements/wind/ropebridge",
    "settlements/wind/windia",
    "settlements/wind/wind",

    "dungeons/earth/levelforest",
    "dungeons/earth/bonedungeon",
    "dungeons/earth/earth",

    "dungeons/water/wintrycave",
    "dungeons/water/fallsbasin",
    "dungeons/water/icepyramid",
    "dungeons/water/water",

    "dungeons/fire/mine",
    "dungeons/fire/volcano",
    "dungeons/fire/lavadome",
    "dungeons/fire/fire",

    "dungeons/wind/gianttree",
    "dungeons/wind/mountgale",
    "dungeons/wind/pazuzutower",
    "dungeons/wind/wind",

    "dungeons/focus-tower/doomcastle",
    "dungeons/focus-tower/macship",
    "dungeons/focus-tower/focus-tower"
  }
  for _, dungMap in pairs(dungMaps) do
    Tracker:AddLayouts("layouts/maps/" .. dungMap .. ".json")
  end
  Tracker:AddLayouts("layouts/maps/world.json")

  Tracker:AddLocations("locations/world.json")

  -- Locations
  locations = {
    -- Center
    "center/main",
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
    "battlefields/earth",
    "battlefields/fire",
    "battlefields/water",
    "battlefields/wind",
  }
  for _, locCat in ipairs(locations) do
    Tracker:AddLocations("locations/overworld/" .. locCat .. ".json")
    if AUTOTRACKER_ENABLE_LOCATION_TRACKING and string.find(locCat, "-") ~= nil then
      Tracker:AddLocations("locations/underworld/" .. locCat .. ".json")
    end
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
