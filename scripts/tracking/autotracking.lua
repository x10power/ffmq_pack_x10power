-- Configuration --------------------------------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = true
-------------------------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:      ", AUTOTRACKER_ENABLE_ITEM_TRACKING)
print("Enable Location Tracking:  ", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Enable Debug Logging:    ", "true")
end
print("---------------------------------------------------------------------")
print("")

function autotracker_started()
    -- Invoked when the auto-tracker is activated/connected
end

U8_READ_CACHE = 0
U8_READ_CACHE_ADDRESS = 0

U16_READ_CACHE = 0
U16_READ_CACHE_ADDRESS = 0

function InvalidateReadCaches()
    U8_READ_CACHE_ADDRESS = 0
    U16_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
    if U8_READ_CACHE_ADDRESS ~= address then
        U8_READ_CACHE = segment:ReadUInt8(address)
        U8_READ_CACHE_ADDRESS = address
    end

    return U8_READ_CACHE
end

function ReadU16(segment, address)
    if U16_READ_CACHE_ADDRESS ~= address then
        U16_READ_CACHE = segment:ReadUInt16(address)
        U16_READ_CACHE_ADDRESS = address
    end

    return U16_READ_CACHE
end

function bSel(b)
    return 2 ^ (b - 1)
end

string.lpad = function(str, len, char)
    if char == nil then char = " " end
    return str .. string.rep(char, len - #str)
end
string.rpad = function(str, len, char)
    if char == nil then char = " " end
    return string.rep(char, len - #str) .. str
end

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

local h2b = {
    ['0']='0000', ['1']='0001', ['2']='0010', ['3']='0011',
    ['4']='0100', ['5']='0101', ['6']='0110', ['7']='0111',
    ['8']='1000', ['9']='1001', ['A']='1010', ['B']='1011',
    ['C']='1100', ['D']='1101', ['E']='1110', ['F']='1111'
}
function hex2bin(n)
    local bin = n:upper():gsub(".", h2b)
    return bin
end
function dec2bin(n)
    local bin = hex2bin(tostring(n):format("%X"))
    return bin:gsub("(.*)%..*$", "%1"):gsub("....","%1 "):gsub(" $","")
end

function isInGame()
    return AutoTracker:ReadU8(0x7e0010, 0) > 0x05
end

function setStateFromValue(value, states, override)
    if not override then
        override = false
    end
    if value then -- If we have a value
        setStage = false
        setToggle = false
        for v, state in pairs(states) do -- Cycle through the possible bits/stages
            if (value & v) > 0 then
                if type(state) == "table" then  -- Progressive Item
                    code = state[1]
                    progressive = Tracker:FindObjectForCode(code)
                    if progressive then
                        stage = state[2]
                        if progressive.CurrentStage or true then
                            if stage == progressive.CurrentStage then -- Setting again to current stage
                                msg = string.lpad(code, 15)
                                msg = string.format(
                                    "%s is already at %d/%d/%s",
                                    msg,
                                    progressive.CurrentStage,
                                    stage,
                                    dec2bin(value)
                                )
                                -- print(msg)
                                setStage = true
                            elseif (stage > progressive.CurrentStage) or override then -- Upgrading
                                msg = string.lpad(code, 15)
                                -- print(value,v,code,stage,progressive.CurrentStage)
                                toggle = Tracker:FindObjectForCode(code .. stage) -- Toggle the toggle
                                if toggle and not toggle.Active then
                                    toggle.Active = true
                                    msg = string.format(
                                        "%s: Toggling [%d].",
                                        msg,
                                        stage
                                    )
                                    setToggle = true
                                end
                                msg = string.format(
                                    "%s Already set: [%d] | [%s]",
                                    msg,
                                    progressive.CurrentStage,
                                    dec2bin(value)
                                )
                                progressive.CurrentStage = stage  -- Upgrade the progressive
                                if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                                    print(msg)
                                end
                                setStage = true
                            else  -- Toggle Item
                                msg = string.lpad(code, 15)
                                toggle = Tracker:FindObjectForCode(code .. stage)
                                if toggle and not toggle.Active then
                                    toggle.Active = true
                                    setToggle = true
                                    msg = string.format(
                                        "%s: Toggling [%d]. Already set: [%d] | [%s]",
                                        msg,
                                        stage,
                                        progressive.CurrentStage,
                                        dec2bin(value)
                                    )
                                    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                                        print(msg)
                                    end
                                end
                                setStage = true
                            end
                        end
                    end
                else  -- Toggle Item
                    code = state
                    toggle = Tracker:FindObjectForCode(code)
                    msg = string.lpad(code, 15)
                    if toggle and not toggle.Active then
                        toggle.Active = true
                        setToggle = true
                        msg = string.format(
                            "%s: Toggling [%s]. | [%s]",
                            msg,
                            "X",
                            dec2bin(value)
                        )
                        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                            print(msg)
                        end
                    end
                end
            end
        end
        if (not setStage) and (not setToggle) and (value > 0) and AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(
                string.format(
                    "%s doesn't map to %s | [%s]",
                    code,
                    value,
                    dec2bin(value)
                )
            )
        end
    end
end

function setStatesFromValues(checks, checkStates, override)
    for i=0, getTableSize(checks) do
        setStateFromValue(checks[i], checkStates[i], override)
    end
end

function updateActivePartyFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        checks = {
            ReadU8(segment, 0x7e004d)
        }
        checkStates = {
            {
                [bSel(4)]= { "party2", 1 }, -- Kaeli
                [bSel(3)]= { "party2", 3 }, -- Reuben
                [bSel(2)]= { "party2", 2 }, -- Phoebe
                [bSel(1)]= { "party2", 4 }  -- Tristam
            }
        }
        setStatesFromValues(checks, checkStates, true)
    end
end

function updateWeaponsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        checks = {
            ReadU8(segment, 0x7e1032),
            ReadU8(segment, 0x7e1033)
        }
        checkStates = {
            {
                [bSel(8)]= { "sword", 1 },  -- Steel Sword
                [bSel(7)]= { "sword", 2 },  -- Knight Sword
                [bSel(6)]= { "sword", 3 },  -- Excalibur
                [bSel(5)]= { "axe",   1 },  -- Axe
                [bSel(4)]= { "axe",   2 },  -- Battle Axe
                [bSel(3)]= { "axe",   3 },  -- Giant's Axe
                [bSel(2)]= { "claw",  1 },  -- Cat Claw
                [bSel(1)]= { "claw",  2 }   -- Charm Claw
            },
            {
                [bSel(8)]= { "claw",  3 },  -- Dragon Claw
                [bSel(7)]= { "bomb",  1 },  -- Bomb
                [bSel(6)]= { "bomb",  2 },  -- Jumbo Bomb
                [bSel(5)]= { "bomb",  3 }   -- Mega Grenade
            }
        }

        print("Weapons")
        setStatesFromValues(checks, checkStates)
        print("")
    end
end

function updateArmorFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        checks = {
            ReadU8(segment, 0x7e1035),
            ReadU8(segment, 0x7e1036),
            ReadU8(segment, 0x7e1037)
        }
        checkStates = {
            {
                [bSel(8)]= { "helmet",  1 },  -- Steel Helm
                [bSel(7)]= { "helmet",  2 },  -- Moon Helm
                [bSel(6)]= { "helmet",  3 },  -- Apollo Helm
                [bSel(5)]= { "armor",   1 },  -- Steel Armor
                [bSel(4)]= { "armor",   2 },  -- Noble Armor
                [bSel(3)]= { "armor",   3 },  -- Gaia's Armor
                [bSel(2)]= { "armor",   4 },  -- Relica Armor
                [bSel(1)]= { "armor",   5 }   -- Mystic Robe
            },
            {
                [bSel(8)]= { "armor",       6 },  -- Flame Armor
                [bSel(7)]= { "armor",       7 },  -- Black Robe
                [bSel(6)]= { "shield",      1 },  -- Steel Shield
                [bSel(5)]= { "shield",      2 },  -- Venus Shield
                [bSel(4)]= { "shield",      3 },  -- Aegis Shield
                [bSel(3)]= { "shield",      4 },  -- Ether Shield
                [bSel(2)]= { "accessories", 1 },  -- Charm
                [bSel(1)]= { "accessories", 2 }   -- Magic Ring
            },
            {
                [bSel(8)]= { "accessories",  3 }   -- Cupid Locket
            }
        }

        print("Armors")
        setStatesFromValues(checks, checkStates)
        print("")
    end
end

function updateSpellFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        checks = {
            ReadU8(segment, 0x7e1038),
            ReadU8(segment, 0x7e1039)
        }
        checkStates = {
            {
                [bSel(8)]= "exit",
                [bSel(7)]= "cure",
                [bSel(6)]= "heal",
                [bSel(5)]= "life",
                [bSel(4)]= "quake",
                [bSel(3)]= "blizzard",
                [bSel(2)]= "fire",
                [bSel(1)]= "aero"
            },
            {
                [bSel(8)]= "thunder",
                [bSel(7)]= "white",
                [bSel(6)]= "meteor",
                [bSel(5)]= "flare"
            }
        }

        print("Spells")
        setStatesFromValues(checks, checkStates)
        print("")
    end
end

function updateItemFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        checks = {
            ReadU8(segment, 0x7e0ea6),
            ReadU8(segment, 0x7e0ea7)
        }
        checkStates = {
            {
                [bSel(8)]= "elixir",
                [bSel(7)]= "treewither",
                [bSel(6)]= "wakewater",
                [bSel(5)]= "venuskey",
                [bSel(4)]= "multikey",
                [bSel(3)]= "gasmask",
                [bSel(2)]= "magicmirror",
                [bSel(1)]= "thunderrock"
            },
            {
                [bSel(8)]= "captaincap",
                [bSel(7)]= "libra",
                [bSel(6)]= "gemini",
                [bSel(5)]= "mobius",
                [bSel(4)]= "sandcoin",
                [bSel(3)]= "rivercoin",
                [bSel(2)]= "suncoin",
                [bSel(1)]= "skycoin"
            }
        }

        print("Items")
        setStatesFromValues(checks, checkStates)
        print("")
    end
end

function updateShardHuntFromMemorySegment(segment)
  if not isInGame() then
      return false
  end

  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then
      shards = ReadU8(segment, 0x7e0e93)
      -- print(shards)
      -- print(SHARD_COUNT)
      print("SkyShards")
      Tracker:FindObjectForCode(SHARD_COUNT).AcquiredCount = shards
      print("")
    end
end

ScriptHost:AddMemoryWatch("FFMQ Active Party Member Data", 0x7e004d, 0x1FF, updateActivePartyFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Item Data", 0x7e0ea6, 0x1FF, updateItemFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Shard Hunt Data", 0x7e0e93, 0x01, updateShardHuntFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Weapon Data", 0x7e1032, 0x1F0, updateWeaponsFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Armor Data", 0x7e1035, 0x280, updateArmorFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Spell Data", 0x7e1038, 0x1F0, updateSpellFromMemorySegment)
