-- Version
ScriptHost:LoadScript("scripts/ver.lua")

-- Settings
-- ScriptHost:LoadScript("scripts/settings/settings.lua")

-- Auto-Tracking
-- ScriptHost:LoadScript("scripts/tracking/autotracking.lua")

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

local variant = Tracker.ActiveVariantUID
if variant == "" then
  variant = "items_only"
end

if string.find(variant, "map") then
  print("Map Variant; load map stuff")
  -- World Map
  Tracker:AddMaps("maps/maps.json")
  -- Dungeon Maps
  Tracker:AddMaps("maps/dungeons/lavadome.json")
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
    -- Earth
    "earth/main",
    "earth/foresta",
    -- Fire
    "fire/main",
    "fire/fireburg",
    -- Water
    "water/main",
    "water/aquaria",
    -- Wind
    "wind/main",
    "wind/windia"
  }
  for _, locCat in ipairs(locations) do
    Tracker:AddLocations("locations/" .. locCat .. ".json")
  end
  print("")
else
  print("Not a Map Variant; load default stuff")
  -- Layout Defaults
  Tracker:AddLayouts("layouts/broadcast.json")
  Tracker:AddLayouts("layouts/tracker.json")
  print("")

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
end
