ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/custom_item.lua")
ScriptHost:LoadScript("scripts/ganongoal.lua")
ScriptHost:LoadScript("scripts/settings.lua")
local goalsign = GanonGoalItem("Goal Sign", "goalsign")

-- Items
Tracker:AddItems("items/items.json")

-- Tracker Layout
Tracker:AddLayouts("layouts/tracker.json")

-- Broadcast Layout
Tracker:AddLayouts("layouts/broadcast.json")

if Tracker.ActiveVariantUID == "items_only" then
  -- Default/Items-Only
  Tracker:AddLayouts("variants/" .. Tracker.ActiveVariantUID .. "/layouts/tracker.json")    -- Main Tracker
  Tracker:AddLayouts("variants/" .. Tracker.ActiveVariantUID .. "/layouts/broadcast.json")  -- Broadcast View
end

if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end
