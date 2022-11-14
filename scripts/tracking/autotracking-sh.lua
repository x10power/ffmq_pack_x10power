-- Configuration --------------------------------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = false
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

function isInGame()
    return AutoTracker:ReadU8(0x7e0010, 0) > 0x05
end

function updateWeaponsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        weapon1 = ReadU8(segment, 0x7e1032)
        weapon2 = ReadU8(segment, 0x7e1033)
        if (weapon1 & 0x80) > 0 then Tracker:FindObjectForCode("sword").CurrentStage = 1 end 
        if (weapon1 & 0x40) > 0 then Tracker:FindObjectForCode("sword").CurrentStage = 2 end 
        if (weapon1 & 0x20) > 0 then Tracker:FindObjectForCode("sword").CurrentStage = 3 end 
        if (weapon1 & 0x10) > 0 then Tracker:FindObjectForCode("axe").CurrentStage = 1 end 
        if (weapon1 & 0x08) > 0 then Tracker:FindObjectForCode("axe").CurrentStage = 2 end 
        if (weapon1 & 0x04) > 0 then Tracker:FindObjectForCode("axe").CurrentStage = 3 end 
        if (weapon1 & 0x02) > 0 then Tracker:FindObjectForCode("claw").CurrentStage = 1 end 
        if (weapon1 & 0x01) > 0 then Tracker:FindObjectForCode("claw").CurrentStage = 2 end 
        if (weapon2 & 0x80) > 0 then Tracker:FindObjectForCode("claw").CurrentStage = 3 end 
        if (weapon2 & 0x40) > 0 then Tracker:FindObjectForCode("bomb").CurrentStage = 1 end 
        if (weapon2 & 0x20) > 0 then Tracker:FindObjectForCode("bomb").CurrentStage = 2 end 
        if (weapon2 & 0x10) > 0 then Tracker:FindObjectForCode("bomb").CurrentStage = 3 end 

    end
end

function updateArmorFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        armor1 = ReadU8(segment, 0x7e1035)
        armor2 = ReadU8(segment, 0x7e1036)
        armor3 = ReadU8(segment, 0x7e1037)
        if (armor1 & 0x80) > 0 then Tracker:FindObjectForCode("helmet").CurrentStage = 1 end 
        if (armor1 & 0x40) > 0 then Tracker:FindObjectForCode("helmet").CurrentStage = 2 end 
        if (armor1 & 0x20) > 0 then Tracker:FindObjectForCode("helmet").CurrentStage = 3 end 
        if (armor1 & 0x10) > 0 then Tracker:FindObjectForCode("armors").CurrentStage = 1 end 
        if (armor1 & 0x08) > 0 then Tracker:FindObjectForCode("armors").CurrentStage = 2 end 
        if (armor1 & 0x04) > 0 then Tracker:FindObjectForCode("armors").CurrentStage = 3 end 
        -- if (armor1 & 0x02) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Relica Armor
        -- if (armor1 & 0x01) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Mystic Robe
        -- if (armor2 & 0x80) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Flame Armor
        -- if (armor2 & 0x40) > 0 then Tracker:FindObjectForCode("armors").CurrentStage =  end  -- Black Robe
        if (armor2 & 0x20) > 0 then Tracker:FindObjectForCode("shield").CurrentStage = 1 end 
        if (armor2 & 0x10) > 0 then Tracker:FindObjectForCode("shield").CurrentStage = 2 end 
        if (armor2 & 0x08) > 0 then Tracker:FindObjectForCode("shield").CurrentStage = 3 end 
        -- if (armor2 & 0x04) > 0 then Tracker:FindObjectForCode("shield").CurrentStage =  end  -- Ether Shield
        if (armor2 & 0x02) > 0 then Tracker:FindObjectForCode("accessories").CurrentStage = 1 end 
        if (armor2 & 0x01) > 0 then Tracker:FindObjectForCode("accessories").CurrentStage = 2 end 
        if (armor3 & 0x80) > 0 then Tracker:FindObjectForCode("accessories").CurrentStage = 3 end 
   
    end
end

function updateSpellFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        spell1 = ReadU8(segment, 0x7e1038)
        spell2 = ReadU8(segment, 0x7e1039)
        if (spell1 & 0x80) > 0 then Tracker:FindObjectForCode("exit").Active = true end 
        if (spell1 & 0x40) > 0 then Tracker:FindObjectForCode("cure").Active = true end
        if (spell1 & 0x20) > 0 then Tracker:FindObjectForCode("heal").Active = true end
        if (spell1 & 0x10) > 0 then Tracker:FindObjectForCode("life").Active = true end 
        if (spell1 & 0x08) > 0 then Tracker:FindObjectForCode("quake").Active = true end 
        if (spell1 & 0x04) > 0 then Tracker:FindObjectForCode("blizzard").Active = true end
        if (spell1 & 0x02) > 0 then Tracker:FindObjectForCode("fire").Active = true end
        if (spell1 & 0x01) > 0 then Tracker:FindObjectForCode("aero").Active = true end 
        if (spell2 & 0x80) > 0 then Tracker:FindObjectForCode("thunder").Active = true end 
        if (spell2 & 0x40) > 0 then Tracker:FindObjectForCode("white").Active = true end 
        if (spell2 & 0x20) > 0 then Tracker:FindObjectForCode("meteor").Active = true end 
        if (spell2 & 0x10) > 0 then Tracker:FindObjectForCode("flare").Active = true end
        
    end
end

function updateItemFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        item1 = ReadU8(segment, 0x7e0ea6)
        item2 = ReadU8(segment, 0x7e0ea7)
        if (item1 & 0x80) > 0 then Tracker:FindObjectForCode("elixir").Active = true end 
        if (item1 & 0x40) > 0 then Tracker:FindObjectForCode("treewither").Active = true end
        if (item1 & 0x20) > 0 then Tracker:FindObjectForCode("wakewater").Active = true end
        if (item1 & 0x10) > 0 then Tracker:FindObjectForCode("venuskey").Active = true end 
        if (item1 & 0x08) > 0 then Tracker:FindObjectForCode("multikey").Active = true end 
        if (item1 & 0x04) > 0 then Tracker:FindObjectForCode("gasmask").Active = true end
        if (item1 & 0x02) > 0 then Tracker:FindObjectForCode("magicmirror").Active = true end
        if (item1 & 0x01) > 0 then Tracker:FindObjectForCode("thunderrock").Active = true end 
        if (item2 & 0x80) > 0 then Tracker:FindObjectForCode("captaincap").Active = true end 
        if (item2 & 0x40) > 0 then Tracker:FindObjectForCode("libra").Active = true end
        if (item2 & 0x20) > 0 then Tracker:FindObjectForCode("gemini").Active = true end
        if (item2 & 0x10) > 0 then Tracker:FindObjectForCode("mobius").Active = true end 
        if (item2 & 0x08) > 0 then Tracker:FindObjectForCode("sandcoin").Active = true end 
        if (item2 & 0x04) > 0 then Tracker:FindObjectForCode("rivercoin").Active = true end
        if (item2 & 0x02) > 0 then Tracker:FindObjectForCode("suncoin").Active = true end
        if (item2 & 0x01) > 0 then Tracker:FindObjectForCode("skycoin").Active = true end 
        
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
        print(SHARD_COUNT)
        Tracker:FindObjectForCode(SHARD_COUNT).AcquiredCount = shards
        
    end
end

ScriptHost:AddMemoryWatch("FFMQ Weapon Data", 0x7e1032, 0x1F0, updateWeaponsFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Armor Data", 0x7e1035, 0x280, updateArmorFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Spell Data", 0x7e1038, 0x1F0, updateSpellFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Item Data", 0x7e0EA6, 0x1FF, updateItemFromMemorySegment)
ScriptHost:AddMemoryWatch("FFMQ Shard Hunt Data", 0x7e0e93, 0x01, updateShardHuntFromMemorySegment)

