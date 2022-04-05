-- Items
--  Armor
Tracker:AddItems("items/armor.json")
--  Magics
Tracker:AddItems("items/magics.json")
--  Weapons
Tracker:AddItems("items/weapons.json")
--  Toggles
Tracker:AddItems("items/toggles.json")

if Tracker.ActiveVariantUID == "items_only" then
  -- Default/Items-Only
  Tracker:AddLayouts("variants/" .. Tracker.ActiveVariantUID .. "/layouts/tracker.json")    -- Main Tracker
  Tracker:AddLayouts("variants/" .. Tracker.ActiveVariantUID .. "/layouts/broadcast.json")  -- Broadcast View
end
