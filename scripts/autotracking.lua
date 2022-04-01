-- Configuration --------------------------------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = false
-------------------------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:        ", AUTOTRACKER_ENABLE_ITEM_TRACKING)
print("Enable Location Tracking:    ", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Enable Debug Logging:        ", "true")
end
print("---------------------------------------------------------------------")
print("")

function autotracker_started()
    -- Invoked when the auto-tracker is activated/connected
end

AUTOTRACKER_IS_IN_TRIFORCE_ROOM = false
AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY = false

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

function updateInGameStatusFromMemorySegment(segment)

    local mainModuleIdx = segment:ReadUInt8(0x7e0010)

    local wasInTriforceRoom = AUTOTRACKER_IS_IN_TRIFORCE_ROOM
    AUTOTRACKER_IS_IN_TRIFORCE_ROOM = (mainModuleIdx == 0x19 or mainModuleIdx == 0x1a)

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        if mainModuleIdx > 0x05 then
            print("Current Room Index: ", segment:ReadUInt16(0x7e00a0))
            print("Current OW   Index: ", segment:ReadUInt16(0x7e008a))
        end
        return false
    end

    return true
end

function updateConsumableItemFromTwoByteSum(segment, code, address, address2)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        local value2 = ReadU8(segment, address2)
        item.CurrentStage = value + value2
    else
        print("Couldn't find item: ", code)
    end
end

function updateProgressiveItemFromByte(segment, code, address, offset)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        item.CurrentStage = value + (offset or 0)
    end
end

function updateAga1(segment)
    local item = Tracker:FindObjectForCode("aga1")
    local value = ReadU8(segment, 0x7ef3c5)
    if value >= 3 then
        item.Active = true
    else
        item.Active = false
    end
end

function updateBottles(segment)
    local item = Tracker:FindObjectForCode("bottle")    
    local count = 0
    for i = 0, 3, 1 do
        if ReadU8(segment, 0x7ef35c + i) > 0 then
            count = count + 1
        end
    end
    item.CurrentStage = count
end

function updateToggleItemFromByte(segment, code, address)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if value > 0 then
            item.Active = true
        else
            item.Active = false
        end
    end
end

function updateMirrorFromByte(segment, code, address)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if value > 1 then
            item.Active = true
        else
            item.Active = false
        end
    end
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, code, flag)
        end

        local flagTest = value & flag

        if flagTest ~= 0 then
            item.Active = true
        else
            item.Active = false
        end
    end
end

function updateToggleFromRoomSlot(segment, code, slot)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))
        
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(roomData)
        end

        item.Active = (roomData & (1 << slot[2])) ~= 0
    end
end

function updateFlute(segment)
    local item = Tracker:FindObjectForCode("flute")
    local value = ReadU8(segment, 0x7ef38c)

    local fakeFlute = value & 0x02
    local realFlute = value & 0x01

    if realFlute ~= 0 then
        item.Active = true
    elseif fakeFlute ~= 0 then
        item.Active = true
    else
        item.Active = false
    end
end

function updateConsumableItemFromByte(segment, code, address)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        item.CurrentStage = value
    else
        print("Couldn't find item: ", code)
    end
end

function updatePseudoProgressiveItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        local flagTest = value & flag

        if flagTest ~= 0 then
            item.CurrentStage = math.max(1, item.CurrentStage)
        else
            item.CurrentStage = 0
        end    
    end
end

function updateSectionChestCountFromByteAndFlag(segment, locationRef, address, flag, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
        end

        if (value & flag) ~= 0 then
            location.AvailableChestCount = 0
            if callback then
                callback(true)
            end
        else
            location.AvailableChestCount = location.ChestCount
            if callback then
                callback(false)
            end
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateSectionChestCountFromOverworldIndexAndFlag(segment, locationRef, index, callback)
    updateSectionChestCountFromByteAndFlag(segment, locationRef, 0x7ef280 + index, 0x40, callback)
end

function updateSectionChestCountFromRoomSlotList(segment, locationRef, roomSlots, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local clearedCount = 0
        for i,slot in ipairs(roomSlots) do
            local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(locationRef, roomData, 1 << slot[2])
            end
                
            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            end
        end

        location.AvailableChestCount = location.ChestCount - clearedCount

        if callback then
            callback(clearedCount > 0)
        end
    end
end

function updateNPCItemFlagsFromMemorySegment(segment)
    return true
end

function updateOverworldEventsFromMemorySegment(segment)
    return true
end

function updateRoomsFromMemorySegment(segment)

    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        updateToggleFromRoomSlot(segment, "ep", { 200, 11 })
        updateToggleFromRoomSlot(segment, "dp", { 51, 11 })
        updateToggleFromRoomSlot(segment, "toh", { 7, 11 })
        updateToggleFromRoomSlot(segment, "pod", { 90, 11 })
        updateToggleFromRoomSlot(segment, "sp", { 6, 11 })
        updateToggleFromRoomSlot(segment, "sw", { 41, 11 })
        updateToggleFromRoomSlot(segment, "tt", { 172, 11 })
        updateToggleFromRoomSlot(segment, "ip", { 222, 11 })
        updateToggleFromRoomSlot(segment, "mm", { 144, 11 })
        updateToggleFromRoomSlot(segment, "tr", { 164, 11 })
        return true
    end
end

function updateItemsFromMemorySegment(segment)

    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then

        updateProgressiveItemFromByte(segment, "sword",  0x7ef359, 0)
        updateProgressiveItemFromByte(segment, "shield", 0x7ef35a, 0)
        updateProgressiveItemFromByte(segment, "armor",  0x7ef35b, 0)
        updateProgressiveItemFromByte(segment, "gloves", 0x7ef354, 0)
        
        updateToggleItemFromByte(segment, "hookshot",  0x7ef342)
        updateToggleItemFromByte(segment, "bombs",     0x7ef343)
        updateToggleItemFromByte(segment, "firerod",   0x7ef345)
        updateToggleItemFromByte(segment, "icerod",    0x7ef346)
        updateToggleItemFromByte(segment, "bombos",    0x7ef347)
        updateToggleItemFromByte(segment, "ether",     0x7ef348)
        updateToggleItemFromByte(segment, "quake",     0x7ef349)
        updateToggleItemFromByte(segment, "lamp",      0x7ef34a)
        updateToggleItemFromByte(segment, "hammer",    0x7ef34b)
        updateToggleItemFromByte(segment, "net",       0x7ef34d)
        updateToggleItemFromByte(segment, "book",      0x7ef34e)
        updateToggleItemFromByte(segment, "somaria",   0x7ef350)
        updateToggleItemFromByte(segment, "byrna",     0x7ef351)
        updateToggleItemFromByte(segment, "cape",      0x7ef352)
        updateMirrorFromByte(segment, "mirror",    0x7ef353)
        updateToggleItemFromByte(segment, "boots",     0x7ef355)
        updateToggleItemFromByte(segment, "flippers",  0x7ef356)
        updateToggleItemFromByte(segment, "pearl",     0x7ef357)
        updateToggleItemFromByte(segment, "halfmagic", 0x7ef37b)

        updateToggleItemFromByteAndFlag(segment, "blueboom", 0x7ef38c, 0x80)
        updateToggleItemFromByteAndFlag(segment, "redboom",  0x7ef38c, 0x40)
        updateToggleItemFromByteAndFlag(segment, "powder", 0x7ef38c, 0x10)
        updateToggleItemFromByteAndFlag(segment, "bow", 0x7ef38e, 0x80)
        updateToggleItemFromByteAndFlag(segment, "silvers", 0x7ef38e, 0x40)

        updateToggleItemFromByteAndFlag(segment, "mushroom", 0x7ef38c, 0x20)
        updateToggleItemFromByteAndFlag(segment, "shovel", 0x7ef38c, 0x04)

        updateBottles(segment)
        updateFlute(segment)
        updateAga1(segment)

        updateToggleItemFromByteAndFlag(segment, "gtbk",  0x7ef366, 0x04)
        updateToggleItemFromByteAndFlag(segment, "trbk",  0x7ef366, 0x08)
        updateToggleItemFromByteAndFlag(segment, "ttbk",  0x7ef366, 0x10)
        updateToggleItemFromByteAndFlag(segment, "tohbk", 0x7ef366, 0x20)
        updateToggleItemFromByteAndFlag(segment, "ipbk",  0x7ef366, 0x40)    
        updateToggleItemFromByteAndFlag(segment, "swbk",  0x7ef366, 0x80)
        updateToggleItemFromByteAndFlag(segment, "mmbk",  0x7ef367, 0x01)
        updateToggleItemFromByteAndFlag(segment, "podbk", 0x7ef367, 0x02)
        updateToggleItemFromByteAndFlag(segment, "spbk",  0x7ef367, 0x04)
        updateToggleItemFromByteAndFlag(segment, "dpbk",  0x7ef367, 0x10)
        updateToggleItemFromByteAndFlag(segment, "epbk",  0x7ef367, 0x20)
        local item = Tracker:FindObjectForCode("hcdoor")
        if item then
            updateToggleItemFromByteAndFlag(segment, "hcdoor",  0x7ef367, 0x40) 
        end
        item = Tracker:FindObjectForCode("atdoor")
        if item then
            updateToggleItemFromByteAndFlag(segment, "atdoor",  0x7ef367, 0x08)
        end
    end
end

function updateChestKeysFromMemorySegment(segment)

    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then

        -- Pending small key from chests tracking update
        -- Sewers is unused by the game - this is here for reference sake
        -- updateConsumableItemFromByte(segment, "sewers_smallkey",  0x7ef4e0)
        updateConsumableItemFromTwoByteSum(segment, "hcsk", 0x7ef4e0, 0x7ef4e1)
        updateConsumableItemFromByte(segment, "epsk",  0x7ef4e2)
        updateConsumableItemFromByte(segment, "dpsk",  0x7ef4e3)
        updateConsumableItemFromByte(segment, "atsk",  0x7ef4e4)
        updateConsumableItemFromByte(segment, "spsk",  0x7ef4e5)
        updateConsumableItemFromByte(segment, "podsk", 0x7ef4e6)
        updateConsumableItemFromByte(segment, "mmsk",  0x7ef4e7)
        updateConsumableItemFromByte(segment, "swsk",  0x7ef4e8)
        updateConsumableItemFromByte(segment, "ipsk",  0x7ef4e9)
        updateConsumableItemFromByte(segment, "tohsk", 0x7ef4ea)
        updateConsumableItemFromByte(segment, "ttsk",  0x7ef4eb)
        updateConsumableItemFromByte(segment, "trsk",  0x7ef4ec)
        updateConsumableItemFromByte(segment, "gtsk",  0x7ef4ed)
       
    end
end

-- Run the in-game status check more frequently (every 250ms) to catch save/quit scenarios more effectively
ScriptHost:AddMemoryWatch("LTTP In-Game status", 0x7e0010, 0x90, updateInGameStatusFromMemorySegment, 250)
ScriptHost:AddMemoryWatch("LTTP Item Data", 0x7ef340, 0x90, updateItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Room Data", 0x7ef000, 0x250, updateRoomsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Overworld Event Data", 0x7ef280, 0x82, updateOverworldEventsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP NPC Item Data", 0x7ef410, 2, updateNPCItemFlagsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Chest Key Data", 0x7ef4e0, 0x10, updateChestKeysFromMemorySegment)
