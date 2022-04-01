ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/custom_item.lua")
ScriptHost:LoadScript("scripts/ganongoal.lua")
ScriptHost:LoadScript("scripts/settings.lua")
local goalsign = GanonGoalItem("Goal Sign","goalsign")
Tracker:AddItems("items/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
else    
    print("Auto-tracker is unsupported by your tracker version")
end