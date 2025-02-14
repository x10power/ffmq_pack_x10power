toggles = {}

function trim(s)
    local n = s:find"%S"
    return n and s:match(".*%S", n) or ""
end

function tokenize(input)
    return string.lower(
        input:gsub("%s+", ""):gsub("'s","")
    )
end

function ucfirst(input)
    return (input:gsub("^%l", string.upper))
end

function titleCaseMatcher( first, rest )
    return first:upper()..rest:lower()
end

function titleCase(str)
    return str:gsub("(%a)([%w_']*)", titleCaseMatcher)
end

-- Armor
for slot,items in pairs(
    {
        ["helmet"]      = {"steel","moon","apollo"},
        ["armor"]       = {"steel","noble","gaia's"},
        ["shield"]      = {"steel","venus","aegis"},
        ["accessories"] = {"charm","magic ring","cupid locket"}
    }
) do
    for lvl,item in pairs(items) do
        local name = item .. " " .. slot
        local dir = slot
        local filename = slot .. lvl .. ".png"
        if dir == "helmet" then
            dir = "hat"
        end
        name = name:gsub("helmet","helm")
        name = name:gsub("accessories","")
        if dir == "accessories" then
            filename = tokenize(name) .. ".png"
        end
        table.insert(
            toggles,
            {
                ["name"] = trim(titleCase(name)),
                ["code"] = slot .. lvl,
                ["img"] = "images/armor/" .. dir .. "/" .. filename
            }
        )
    end
end

-- Coins
for _,coin in ipairs(
    {
        "sand",
        "river",
        "sun"
    }
) do
    table.insert(
        toggles,
        {
            ["name"] = coin .. " Coin",
            ["code"] = coin .. ", " .. coin .. "coin",
            ["img"] = "images/coins/coin_" .. coin .. ".png"
        }
    )
end

-- Crests
for _,crest in ipairs(
    {
        "libra",
        "gemini",
        "mobius"
    }
) do
    table.insert(
        toggles,
        {
            ["name"] = crest .. " Crest",
            ["code"] = crest .. ", " .. crest .. "crest",
            ["img"] = "images/crests/crest.png",
            ["imgMods"] = "overlay|images/crests/overlay/" .. crest .. ".png"
        }
    )
end

-- Crystals
for _,crystal in ipairs(
    {
        "earth",
        "water",
        "fire",
        "wind",
        "light"
    }
) do
    table.insert(
        toggles,
        {
            ["name"] = "Crystal of " .. ucfirst(crystal),
            ["code"] = crystal .. "crystal, crystal",
            ["img"] = "images/crystals/crystal_" .. crystal .. ".png"
        }
    )
end

-- Magics
for color,spells in pairs(
    {
        ["white"] = {"exit","cure","heal","life"},
        ["black"] = {"quake","blizzard","fire","aero"},
        ["wizard"] = {"thunder","white","meteor","flare"}
    }
) do
    for _,spell in pairs(spells) do
        table.insert(
            toggles,
            {
                ["name"] = spell,
                ["code"] = spell .. ", " .. spell .. "book",
                ["img"] = "images/magic/" .. color .. "/" .. color .. "magic.png",
                ["imgMods"] = "overlay|images/magic/" .. color .. "/overlay/" .. spell .. ".png"
            }
        )
    end
end

-- Storymarkers (Boss Tokens)
for _,dungeon in pairs(
    {
        "Level Forest",
        "Bone Dungeon",
        "Wintry Cave",
        "Falls Basin",
        "Ice Pyramid",
        "Mine",
        "Volcano",
        "Lava Dome",
        "Giant Tree",
        "Mount Gale",
        "Pazuzu's Tower",
        "Mac's Ship",
        "Doom Castle"
    }
) do
    local name = "Boss: " .. dungeon
    local code = "boss_" .. tokenize(dungeon)
    local minibosses = {
        ["Level Forest"] = true,
        ["Wintry Cave"] = true,
        ["Falls Basin"] = true,
        ["Mine"] = true,
        ["Volcano"] = true,
        ["Giant Tree"] = true,
        ["Mount Gale"] = true,
        ["Mac's Ship"] = true
    }
    if minibosses[dungeon] then
        name = name:gsub("Boss:","Miniboss:")
        code = code .. ",miniboss"
    end
    table.insert(
        toggles,
        {
            ["name"] = name,
            ["code"] = code,
            ["img"] = "images/bosstokens/" .. tokenize(dungeon) .. ".png"
        }
    )
end

-- Weapons
for slot,items in pairs(
    {
        ["sword"]   = {"steel","knight","excalibur"},
        ["axe"]     = {"axe","battle","giant's"},
        ["bomb"]    = {"bomb","jumbo","mega grenade"},
        ["claw"]    = {"cat","charm","dragon"}
    }
) do
    for lvl,item in pairs(items) do
        local name = item
        local namedItems = {
            ["excalibur"] = true,
            ["mega grenade"] = true
        }
        if name ~= slot then
            if namedItems[item] == nil then
                name = item .. " " .. slot
            end
        end
        table.insert(
            toggles,
            {
                ["name"] = trim(titleCase(name)),
                ["code"] = slot .. lvl,
                ["img"] = "images/inventory/weapons/" .. slot .. lvl .. ".png"
            }
        )
    end
end

-- Basics
for _,item in pairs(
    {
        "Venus Key",
        "Multi Key",
        "Gas Mask",
        "Magic Mirror"
    }
) do
    table.insert(
        toggles,
        {
            ["name"] = titleCase(item),
            ["code"] = tokenize(item),
            ["img"] = "images/inventory/" .. tokenize(item) .. ".png"
        }
    )
end

for _,item in ipairs(toggles) do
    ToggleItem(
        ucfirst(item["name"]),
        item["code"],
        item["img"],
        item["imgMods"] or ""
    )
end
