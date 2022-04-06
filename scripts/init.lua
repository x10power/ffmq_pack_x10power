-- Items
--  Armor
Tracker:AddItems("items/armor.json")
--  Magics
Tracker:AddItems("items/magics.json")
--  Weapons
Tracker:AddItems("items/weapons.json")
--  Toggles
Tracker:AddItems("items/toggles.json")

local variant = Tracker.ActiveVariantUID
if variant == "" then
  variant = "items_only"
end

if string.find(variant, "map") then
  -- Maps
  Tracker:AddMaps("maps/maps.json")
  -- Map Layouts
  Tracker:AddLayouts("layouts/maps/world.json")

  -- Locations
  --  World
  Tracker:AddLocations("locations/world.json")
  --  Center
  Tracker:AddLocations("locations/center/focustower.json")
  --  Earth
  Tracker:AddLocations("locations/earth/foresta.json")
  Tracker:AddLocations("locations/earth/hod.json")
  Tracker:AddLocations("locations/earth/levelforest.json")
end

Tracker:AddLayouts("variants/" .. variant .. "/layouts/tracker.json")    -- Main Tracker
Tracker:AddLayouts("variants/" .. variant .. "/layouts/broadcast.json")  -- Broadcast View
