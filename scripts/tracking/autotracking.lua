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

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function isInGame()
    return AutoTracker:ReadU8(0x7e0010, 0) > 0x05
end

function setStateFromValue(value, states)
    if value then
        for v, state in pairs(states) do
            if (value & v) > 0 then
                if type(state) == "table" then
                    code = state[1]
                    obj = Tracker:FindObjectForCode(code)
                    if obj then
                        stage = state[2]
                        if obj.CurrentStage then
                            if stage == obj.CurrentStage then
                                return
                            elseif stage > obj.CurrentStage then
                                print(value,v,code,stage)
                                obj.CurrentStage = stage
                            else
                                print(
                                    string.format(
                                        "Would downgrade %s from %d to %d",
                                        code,
                                        obj.CurrentStage,
                                        stage
                                    )
                                )
                            end
                        end
                    end
                else
                    code = state
                    obj = Tracker:FindObjectForCode(code)
                    if obj then
                        obj.Active = true
                    end
                end
            end
        end
    end
end

function setStatesFromValues(checks, checkStates)
    for i=0, getTableSize(checks) do
        setStateFromValue(checks[i], checkStates[i])
    end
end

function updatePartyFromMemorySegment(segment)
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
                [0x04]= { "party2", 3 },
                [0x02]= { "party2", 2 }
            }
        }
        setStatesFromValues(checks, checkStates)
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
                [0x80]= { "swords",  1 },
                [0x40]= { "swords",  2 },
                [0x20]= { "swords",  3 },
                [0x10]= { "axes",    1 },
                [0x08]= { "axes",    2 },
                [0x04]= { "axes",    3 },
                [0x02]= { "claws",   1 },
                [0x01]= { "claws",   2 }
            },
            {
                [0x80]= { "claws",   3 },
                [0x40]= { "bombs",   1 },
                [0x20]= { "bombs",   2 },
                [0x10]= { "bombs",   3 }
            }
        }

        setStatesFromValues(checks, checkStates)
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
        -- if (armor1 & 0x02) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Relica Armor
        -- if (armor1 & 0x01) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Mystic Robe
        -- if (armor2 & 0x80) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Flame Armor
        -- if (armor2 & 0x40) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Black Robe
        -- if (armor2 & 0x04) > 0 then Tracker:FindObjectForCode("shield").CurrentStage =  end  -- Ether Shield
        checkStates = {
            {
                [0x80]= { "helmet", 1 },
                [0x40]= { "helmet", 2 },
                [0x20]= { "helmet", 3 },
                [0x10]= { "armors", 1 },
                [0x08]= { "armors", 2 },
                [0x04]= { "armors", 3 },
                [0x02]= { "armors", 4 },
                [0x01]= { "armors", 5 }
            },
            {
                [0x80]= { "armors",       6 },
                [0x40]= { "armors",       7 },
                [0x20]= { "shields",      1 },
                [0x10]= { "shields",      2 },
                [0x08]= { "shields",      3 },
                [0x04]= { "accessories",  1 },
                [0x02]= { "accessories",  2 }
            },
            {
                [0x80]= { "accessories",  3 }
            }
        }

        setStatesFromValues(checks, checkStates)
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
                [0x80]= "exit",
                [0x40]= "cure",
                [0x20]= "heal",
                [0x10]= "life",
                [0x08]= "quake",
                [0x04]= "blizzard",
                [0x02]= "fire",
                [0x01]= "aero"
            },
            {
                [0x80]= "thunder",
                [0x40]= "white",
                [0x20]= "meteor",
                [0x10]= "flare"
            }
        }

        setStatesFromValues(checks, checkStates)
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
                [0x80]= "elixir",
                [0x40]= "treewither",
                [0x20]= "wakewater",
                [0x10]= "venuskey",
                [0x08]= "multikey",
                [0x04]= "gasmask",
                [0x02]= "magicmirror",
                [0x01]= "thunderrock"
            },
            {
                [0x80]= "captaincap",
                [0x40]= "libra",
                [0x20]= "gemini",
                [0x10]= "mobius",
                [0x08]= "sandcoin",
                [0x04]= "rivercoin",
                [0x02]= "suncoin",
                [0x01]= "skycoin"
            }
        }

        setStatesFromValues(checks, checkStates)
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
      Tracker:FindObjectForCode(SHARD_COUNT).AcquiredCount = shards
  end
end

ScriptHost:AddMemoryWatch("FFMQ Potential Party Data", 0x7e004d, 0x1FF, updatePartyFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Item Data", 0x7e0ea6, 0x1FF, updateItemFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Shard Hunt Data", 0x7e0e93, 0x01, updateShardHuntFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Weapon Data", 0x7e1032, 0x1F0, updateWeaponsFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Armor Data", 0x7e1035, 0x280, updateArmorFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Spell Data", 0x7e1038, 0x1F0, updateSpellFromMemorySegment)
