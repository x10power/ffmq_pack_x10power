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

checkedFlags = {
    ["battlefield"] = {},
    ["item"] = {},
    ["npc"] = {}
}

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

--
-- based on https://www.php.net/manual/en/function.str-split.php
-- feel to free to validate/adjust to uses asserto/error
--
-- Denis Dos Santos Silva
--

local function str_split(str, length)
    local result = {}
    local index = 1

    if (type(str) ~= 'string') then return result; end
    local slen = #str;

    if (not length) then length=1; end
    if (length <= 0) then return result; end
    if (length > slen) then return result; end

    while index <= slen do
        table.insert(result, string.sub(str, index, index + length - 1))
        index = index + length
    end

    return result
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
function dec2hex(n)
    return tostring(n):format("%X")
end
function dec2bin(n)
    local bin = hex2bin(dec2hex(n))
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
        msgs = {}
        for v, state in pairs(states) do -- Cycle through the possible bits/stages
            msg = ""
            -- if (bit.bor(value, v) > 0) then
            if (value & v) > 0 then
                local code = ""
                local note = ""
                if type(state) == "table" then  -- Progressive Item
                    code = state[1]
                    progressive = Tracker:FindObjectForCode(code)
                    if progressive then
                        stage = state[2]
                        note = state[3]
                        if progressive.CurrentStage or true then
                            if stage == progressive.CurrentStage then -- Setting again to current stage
                                -- msg = string.lpad(code, 15)
                                -- msg = string.format(
                                --     "%s is already at %d/%d/%s",
                                --     msg,
                                --     progressive.CurrentStage,
                                --     stage,
                                --     dec2bin(value)
                                -- )
                                setStage = true
                            elseif (stage > progressive.CurrentStage) or override then -- Upgrading
                                msg = string.lpad(code, 15)
                                -- print(value,v,code,stage,progressive.CurrentStage)
                                toggle = Tracker:FindObjectForCode(code .. stage) -- Toggle the toggle
                                if not toggle then
                                    toggle = progressive
                                end
                                if toggle and not toggle.Active then
                                    toggle.Active = true
                                    msg = string.format(
                                        "%s: Setting [%d|%s].",
                                        msg,
                                        stage,
                                        note
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
                                setStage = true
                            else  -- Toggle Item
                              toggle = Tracker:FindObjectForCode(code .. stage)
                              if toggle and not toggle.Active then
                                    toggle.Active = true
                                    setToggle = true
                                    msg = string.lpad(code, 15)
                                    msg = string.format(
                                        "%s: Toggling [%d|%s]. Already set: [%d] | [%s]",
                                        msg,
                                        stage,
                                        note,
                                        progressive.CurrentStage,
                                        dec2bin(value)
                                    )
                                end
                                setStage = true
                            end
                        end
                    end
                    if setStage then
                        code = code .. stage
                    end
                else
                    code = state
                end

                if note == "" then
                    note = code
                end

                -- Toggle Item
                toggle = Tracker:FindObjectForCode(code)
                if toggle and not toggle.Active then
                    toggle.Active = true
                    setToggle = true
                    msg = string.lpad(code, 15)
                    msg = string.format(
                        "%s: Toggling [%s|%s]. | [%s]",
                        msg,
                        "X",
                        note,
                        dec2bin(value)
                    )
                end
            end
            if msg ~= "" then
                table.insert(msgs, msg)
            end
        end
        if (not setStage) and (not setToggle) and (value > 0) and AUTOTRACKER_ENABLE_DEBUG_LOGGING and false then
            table.insert(
                msgs,
                string.format(
                    "%s doesn't map to %s | [%s]",
                    code,
                    value,
                    dec2bin(value)
                )
            )
        end
        return msgs
    end
end

function setStatesFromValues(label, checks, checkStates, override)
    printedMsgs = false
    for i=0, getTableSize(checks) do
        msgs = setStateFromValue(checks[i], checkStates[i], override)
        if msgs and (getTableSize(msgs) > 0) then
            print(label)
            printedMsgs = true
            for _, msg in pairs(msgs) do
                print(msg)
            end
        end
    end
    if printedMsgs then
        print("")
    end
end

function updateLocationsFromByteflags(segment, address, offset, locType)
    bitFlag = ReadU8(segment, address + offset)
    if bitFlag > 0 then
        locStart = offset * 8
        locEnd = locStart + 8 - 1
        bitFlags = dec2bin(bitFlag)
        if #bitFlags <= 4 then
            bitFlags = "0000" .. bitFlags
        end
        printedMsgs = false
        for j, bit in ipairs(str_split(bitFlags)) do
            locCurr = locStart + j - 1
            -- print(locType, locCurr, tonumber(bit))
            if tonumber(bit) == 1 then
                if not checkedFlags[locType][locCurr] then
                    roomName = roomIDs[locType][locCurr]
                    if roomName then
                        -- print(
                        --     dec2hex(locCurr),
                        --     roomName
                        -- )
                        -- printedMsgs = true
                        local locFound = false
                        local locQuiet = false
                        checkedFlags[locType][locCurr] = true
                        for k, suffix in pairs({
                            "",
                            "a",
                            "b",
                            "c",
                            "d",
                            "e",
                            "f",
                            "g",
                            "h",
                            "i",
                            "j",
                            "k",
                            "l",
                            "m"
                        }) do
                            local srch = "<sub>"
                            roomSrch = string.gsub(roomName, srch, suffix)
                            local location = Tracker:FindObjectForCode(roomSrch)
                            if not locFound then
                                if location then
                                    print("[" .. locType .. ':' .. locCurr .. "] " .. roomSrch .. " found!")
                                    if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
                                        location.AvailableChestCount = 0
                                    end
                                    locFound = true
                                    printedMsgs = true
                                else
                                    if not locQuiet then
                                        print("!!![" .. locType .. ':' .. locCurr .. "] " .. roomSrch .. " NOT found!")
                                    end
                                    locFound = roomSrch == roomIDs[locType][locCurr]
                                    if not string.find(roomName, srch) then
                                        locFound = true
                                    else
                                        locQuiet = true
                                    end
                                    printedMsgs = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if printedMsgs then
            print("")
        end
    end
end

function updateLocationGroup(segment, address, length, locType)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    -- if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        locType = locType or "item"
        for i=0x00,length,0x01 do
            updateLocationsFromByteflags(segment, address, i, locType)
        end
    -- end
end

function updateLocationGroupsByType(segment, locType)
    if locType == "battlefield" then
        address = 0x7e0fd4
        length = 0x03 - 1
    elseif locType == "item" then
        address = 0x7e0ec8
        length = 0x1F - 1
    elseif locType == "npc" then
        address = 0x7e0ea8
        length = 0x02 - 1
    end
    updateLocationGroup(segment, address, length, locType)
end

function updateLocationGroupsOfBattlefields(segment)
    updateLocationGroupsByType(segment, "battlefield")
end
function updateLocationGroupsOfItems(segment)
    updateLocationGroupsByType(segment, "item")
end
function updateLocationGroupsOfNPCs(segment)
    updateLocationGroupsByType(segment, "npc")
end

function updatePartyQuestFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    end
end

function updateActivePartyFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        -- 0010 1000 Empty  --  40
        -- 0110 1000 Empty  -- 104
        -- 1100 1000 Empty  -- 200
        -- 0111 0111 Kaeli  -- 119
        -- 0111 1000 Kaeli  -- 120
        -- checks = {
        --     ReadU8(segment, 0x7e004d)
        -- }
        -- checkStates = {
        --     {
        --         [bSel(3)]= { "party2", 2, "Reuben"  },
        --         [bSel(2)]= { "party2", 1, "Phoebe"  },
        --         [bSel(1)]= { "party2", 3, "Tristam" }
        --     }
        -- }
        -- setStatesFromValues("Party", checks, checkStates, true)

        party2 = Tracker:FindObjectForCode("party2")
        if party2.CurrentStage then
            partyByte = math.floor(ReadU8(segment, 0x7e004d))
            print("Party:",partyByte)
            companions = {
                [0] = { 0, "Kaeli" },
                [1] = { 1, "Phoebe" },
                [2] = { 2, "Reuben" },
                [3] = { 3, "Tristam" },
                [4] = { 3, "Tristam" }
            }
            if companions[partyByte] then
                party2.CurrentStage = companions[partyByte][1]
                party2.Active = true
            else
                party2.CurrentStage = 0
                party2.Active = false
            end
        end
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
                [bSel(8)]= { "sword", 1, "Steel Sword"  },  -- Steel Sword
                [bSel(7)]= { "sword", 2, "Knight Sword" },  -- Knight Sword
                [bSel(6)]= { "sword", 3, "Excalibur"    },  -- Excalibur
                [bSel(5)]= { "axe",   1, "Axe"          },  -- Axe
                [bSel(4)]= { "axe",   2, "Battle Axe"   },  -- Battle Axe
                [bSel(3)]= { "axe",   3, "Giant's Axe"  },  -- Giant's Axe
                [bSel(2)]= { "claw",  1, "Cat Claw"     },  -- Cat Claw
                [bSel(1)]= { "claw",  2, "Charm Claw"   }   -- Charm Claw
            },
            {
                [bSel(8)]= { "claw",  3, "Dragon Claw"  },
                [bSel(7)]= { "bomb",  1, "Bomb"         },
                [bSel(6)]= { "bomb",  2, "Jumbo Bomb"   },
                [bSel(5)]= { "bomb",  3, "Mega Grenade" }
            }
        }

        setStatesFromValues("Weapons", checks, checkStates)
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
                [bSel(8)]= { "helmet",  1, "Steel Helm"     },
                [bSel(7)]= { "helmet",  2, "Moon Helm"      },
                [bSel(6)]= { "helmet",  3, "Apollo Helm"    },
                [bSel(5)]= { "armor",   1, "Steel Armor"    },
                [bSel(4)]= { "armor",   2, "Noble Armor"    },
                [bSel(3)]= { "armor",   3, "Gaia's Armor"   },
                [bSel(2)]= { "armor",   4, "Relica Armor"   },
                [bSel(1)]= { "armor",   5, "Mystic Robe"    }
            },
            {
                [bSel(8)]= { "armor",       6, "Flame Armor"    },
                [bSel(7)]= { "armor",       7, "Black Robe"     },
                [bSel(6)]= { "shield",      1, "Steel Shield"   },
                [bSel(5)]= { "shield",      2, "Venus Shield"   },
                [bSel(4)]= { "shield",      3, "Aegis Shield"   },
                [bSel(3)]= { "shield",      4, "Ether Shield"   },
                [bSel(2)]= { "accessories", 1, "Charm"          },
                [bSel(1)]= { "accessories", 2, "Magic Ring"     }
            },
            {
                [bSel(8)]= { "accessories",  3, "Cupid Locket"  }
            }
        }

        setStatesFromValues("Armors", checks, checkStates)
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
                [bSel(8)]= "exit",      -- 0x80 128
                [bSel(7)]= "cure",      -- 0x40  64
                [bSel(6)]= "heal",      -- 0x20  32
                [bSel(5)]= "life",      -- 0x10  16
                [bSel(4)]= "quake",     -- 0x08   8
                [bSel(3)]= "blizzard",  -- 0x04   4
                [bSel(2)]= "fire",      -- 0x02   2
                [bSel(1)]= "aero"       -- 0x01   1
            },
            {
                [bSel(8)]= "thunder",
                [bSel(7)]= "white",
                [bSel(6)]= "meteor",
                [bSel(5)]= "flare"
            }
        }

        setStatesFromValues("Spells", checks, checkStates)
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

        setStatesFromValues("Items", checks, checkStates)
    end
end

function updateShardHuntFromMemorySegment(segment)
  if not isInGame() then
      return false
  end

  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then
      shards = ReadU8(segment, 0x7e0e93)
      print(shards)
      print("SkyShards")
      shardsItem = Tracker:FindObjectForCode(SHARD_COUNT)
      if shardsItem then
        shardsItem.AcquiredCount = shards
      end
      print("")
    end
end

ScriptHost:LoadScript("scripts/constants/roomIDs.lua")

ScriptHost:AddMemoryWatch("FFMQ Active Party Member Data", 0x7e004c, 0x03, updateActivePartyFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Collected NPCs Data", 0x7e0ea8, 0x02, updateLocationGroupsOfNPCs)
ScriptHost:AddMemoryWatch("FFMQ Checked Locations Data", 0x7e0ec8, 0x1F, updateLocationGroupsOfItems)
ScriptHost:AddMemoryWatch("FFMQ Completed Battlefields Data", 0x7e0fd4, 0x03, updateLocationGroupsOfBattlefields)
ScriptHost:AddMemoryWatch("FFMQ Item Data", 0x7e0ea6, 0x1FF, updateItemFromMemorySegment)
-- ScriptHost:AddMemoryWatch("FFMQ Party Quest Data", 0x7e0ea8, 0x1FF, updatePartyQuestFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Shard Hunt Data", 0x7e0e93, 0x01, updateShardHuntFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Weapon Data", 0x7e1032, 0x1F0, updateWeaponsFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Armor Data", 0x7e1035, 0x280, updateArmorFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Spell Data", 0x7e1038, 0x1F0, updateSpellFromMemorySegment)
