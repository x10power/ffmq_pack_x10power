-- Version
ScriptHost:LoadScript("scripts/ver.lua")

-- Items
print("Loading Items")
--  Armor
Tracker:AddItems("items/armor.json")
--  Magics
Tracker:AddItems("items/magics.json")
--  Weapons
Tracker:AddItems("items/weapons.json")
--  Toggles
Tracker:AddItems("items/toggles.json")
print("")

-- Layouts
print("Loading Layouts")
--  Armor
Tracker:AddLayouts("layouts/grids/armors.json")
--  Magics
Tracker:AddLayouts("layouts/grids/magics/blackmagics.json")
Tracker:AddLayouts("layouts/grids/magics/whitemagics.json")
Tracker:AddLayouts("layouts/grids/magics/wizardmagics.json")
Tracker:AddLayouts("layouts/grids/magics.json")
--  Weapons
Tracker:AddLayouts("layouts/grids/weapons.json")
--  Toggles
Tracker:AddLayouts("layouts/grids/coins.json")
Tracker:AddLayouts("layouts/grids/crests.json")
Tracker:AddLayouts("layouts/grids/keyitems.json")
--  Grids
Tracker:AddLayouts("layouts/grids/grids.json")
print("")

local variant = Tracker.ActiveVariantUID
if variant == "" then
  variant = "items_only"
end

if string.find(variant, "map") then
  print("Map Variant; load map stuff")
  -- Maps
  Tracker:AddMaps("maps/maps.json")
  -- Map Layouts
  Tracker:AddLayouts("layouts/maps/world.json")

  -- Locations
  --  World
  Tracker:AddLocations("locations/world.json")
  --  Center
  Tracker:AddLocations("locations/center/focustower.json")
  Tracker:AddLocations("locations/center/main.json")
  --  Earth
  Tracker:AddLocations("locations/earth/foresta.json")
  Tracker:AddLocations("locations/earth/hod.json")
  Tracker:AddLocations("locations/earth/levelforest.json")
  Tracker:AddLocations("locations/earth/main.json")
  --  Fire
  Tracker:AddLocations("locations/fire/main.json")
  --  Water
  Tracker:AddLocations("locations/water/main.json")
  --  Wind
  Tracker:AddLocations("locations/wind/main.json")

  -- Layout Overrides
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker.json")    -- Main Tracker
  Tracker:AddLayouts("variants/" .. variant .. "/layouts/broadcast.json")  -- Broadcast View
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
end
