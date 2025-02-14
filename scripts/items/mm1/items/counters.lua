function titleCaseMatcher( first, rest )
    return first:upper()..rest:lower()
end

function titleCase(str)
    return str:gsub("(%a)([%w_']*)", titleCaseMatcher)
end

for _,item in pairs(
    {
        "refreshers",
        "battlefield",
        "battlefields",
        "crystals",
        "minibosses",
        "pazuzu"
    }
) do
    local filename = item .. ".png"
    local name = titleCase("# " .. item)
    local max = QUEST_COUNTERS["quest_" .. item]
    if item == "battlefield" then
        name = "Battlefield Checks"
        max = 5
        filename = "battlefields" .. ".png"
    elseif item == "pazuzu" then
        name = "Pazuzu Checks"
        max = 6
        filename = item .. ".gif"
    end

    local dir = "consumables"
    if item == "battlefield" or
        item == "battlefields" or
        item == "pazuzu" then
        dir = "counters"
    elseif item == "crystals" then
        dir = "crystals"
    elseif item == "minibosses" then
        dir = "bosstokens"
    end

    CollectableItem(
        name,
        item,
        max,
        "images/" .. dir .. "/" .. filename
    )
end

-- Party Quests
for _,member in pairs({
    "kaeli",
    "phoebe",
    "reuben",
    "tristam"
}) do
    CollectableItem(
        ucfirst(member),
        member:lower(),
        4,
        "images/party/" .. member:lower() .. ".gif"
    )
end

-- Battlefields with Item Prize
CollectableItem(
    "Battlefield Item",             -- Name
    "battlefield_item",             -- Code
    nil,                            -- Max
    "images/chests/available.png",  -- ActiveImg
    nil,                            -- InactiveImg
    nil,                            -- ActiveMods
    nil,                            -- InactiveMods
    1                               -- Min
)
-- Battlefields with GP Prize
CollectableItem(
    "Battlefield GP",               -- Name
    "battlefield_gp",               -- Code
    nil,                            -- Max
    "images/battlefields/gp.png",   -- ActiveImg
    nil,                            -- InactiveImg
    nil,                            -- ActiveMods
    nil,                            -- InactiveMods
    1                               -- Min
)
-- Battlefields with XP Prize
CollectableItem(
    "Battlefield XP",               -- Name
    "battlefield_xp",               -- Code
    nil,                            -- Max
    "images/battlefields/xp.png",   -- ActiveImg
    nil,                            -- InactiveImg
    nil,                            -- ActiveMods
    nil,                            -- InactiveMods
    1                               -- Min
)

-- Skyshards
CollectableItem(
    "# Skyshards",
    "skyshards",
    QUEST_COUNTERS["quest_skyshards"],
    "images/coins/coin_sky.png",
    "images/coins/coin_sky.png",
    QUEST_COUNTERS["quest_skyshards"] > 1 and "overlay|images/coins/coin_sky_shroud.png" or ""
)
