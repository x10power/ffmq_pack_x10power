local img = ""
local imgMods = ""
local item = nil

-- Refreshers
RefreshersCountItem = CollectableItem:extend()
img = "images/consumables/refreshers.png"
imgMods = ""
item = RefreshersCountItem(
    "# Refreshers",
    "refreshers",
    QUEST_COUNTERS["quest_refreshers"],
    img,
    img,
    imgMods,
    "@disabled," .. imgMods
)

-- Battlefields
BattlefieldCountItem = CollectableItem:extend()
img = "images/counters/battlefield.png"
imgMods = ""
item = BattlefieldCountItem(
    "# Battlefields",
    "battlefields",
    QUEST_COUNTERS["quest_battlefields"],
    img,
    img,
    imgMods,
    "@disabled," .. imgMods
)

-- Crystals
CrystalCountItem = CollectableItem:extend()
img = "images/crystals/crystals.png"
imgMods = ""
item = CrystalCountItem(
    "# Crystals",
    "crystals",
    QUEST_COUNTERS["quest_crystals"],
    img,
    img,
    imgMods,
    "@disabled," .. imgMods
)

-- Minibosses
MinibossesCountItem = CollectableItem:extend()
img = "images/bosstokens/minibosses.png"
imgMods = ""
item = MinibossesCountItem(
    "# Minibosses",
    "minibosses",
    QUEST_COUNTERS["quest_minibosses"],
    img,
    img,
    imgMods,
    "@disabled," .. imgMods
)

-- Skyshards
ShardCountItem = CollectableItem:extend()
img = "images/coins/coin_sky.png"
imgMods = QUEST_COUNTERS["quest_skyshards"] > 1 and "overlay|images/coins/coin_sky_shroud.png" or ""
item = ShardCountItem(
    "Skyshards",
    "skyshards",
    QUEST_COUNTERS["quest_skyshards"],
    img,
    img,
    imgMods,
    "@disabled," .. imgMods
)
