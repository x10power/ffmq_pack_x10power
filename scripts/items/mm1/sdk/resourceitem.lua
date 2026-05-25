ResourceItem = ConsumableItem:extend()

--[[
    LeftClick:  Decrement
    RightClick: Increment
]]--
function ResourceItem:init(
    name,
    code,
    maxqty,
    img,
    disabledImg,
    imgMods,
    disabledImgMods,
    minqty
)
    print("ResourceItem:",name)
    ConsumableItem.init(
        self,
        name,
        code,
        maxqty,
        img,
        disabledImg,
        imgMods,
        disabledImgMods
    )

    self.name = name
    self.icons = {}
    self.icons.base = {
        ["on"] = {
            ["fname"] = "",
            ["mods"] = ""
        },
        ["off"] = {
            ["fname"] = "",
            ["mods"] = ""
        }
    }

    if img then
        if not disabledImg then
            disabledImg = img
        end
        self.icons.base.on.fname = img

        if imgMods then
            if not disabledImgMods then
                disabledImgMods = imgMods .. ",@disabled"
            end
            self.icons.base.on.mods = imgMods
        else
            if not disabledImgMods then
                disabledImgMods = "@disabled"
            end
        end
    end
    if disabledImg then
        self.icons.base.off.fname = disabledImg
        if disabledImgMods then
            self.icons.base.off.mods = disabledImgMods
        end
    end

    self.MinCount = minqty or 0
    self.Loop = true
end

-- Set Icon
function ResourceItem:setIcon(fname, mods)
    -- FIXME: myIsPopTracker
    if myIsPopTracker() then
        -- print("PopTracker:",self.name,fname,mods)
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath(
            fname
        )
        if mods ~= nil then
            self.ItemInstance.IconMods = mods
        end
    else
        -- print("EmoTracker:",self.name,fname,mods)
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath(
            fname,
            mods
        )
    end
end

function ResourceItem:UpdateBadgeAndIcon()
    -- If we've got any, use Full icon
    -- If we don't have any, use Empty icon
    if self and self.icons then
        if self.AcquiredCount > 0 then
            self:setIcon(self.icons.base.on.fname, self.icons.base.on.mods)
        else
            self:setIcon(self.icons.base.off.fname, self.icons.base.off.mods)
        end
    end
    -- If there's no more to get
    if self.AvailableCount == 0 then
        self.ItemInstance.BadgeText = myIsPopTracker() and "" or nil
    else
        -- If there's more to get
        -- Calculate badge text
        if not self.DisplayAsFractionOfMax then
            if math.floor(self.MaxCount) == 1 then
                self.ItemInstance.BadgeText = nil
            else
                self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount))
            end
        else
            self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount)) .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    -- If we've got >= max
    if self.AcquiredCount >= self.MaxCount then
        -- Set color to green
        self.ItemInstance.BadgeTextColor = "#00ff00"
    else
        -- Else, set color to white
        self.ItemInstance.BadgeTextColor = "#f5f5f5"
        if myIsPopTracker() then
            self.ItemInstance:SetOverlayBackground("#000000")
            self.ItemInstance:SetOverlayFontSize(12)
        end
    end
end

function ResourceItem:InvalidateAccessibility()
    if myIsPopTracker() then
        return
    end
    self.ItemInstance:InvalidateAccessibility()
end

function ResourceItem:AdjustCount(direction, count)
    count = count or 1
    local adjust = self.AcquiredCount + (self.CountIncrement * count)
    if direction == "down" then
        adjust = self.AcquiredCount - (self.CountIncrement * count)
    end
    local num = math.min(
        self.MaxCount,
        math.max(
            self.MinCount,
            adjust
        )
    )
    if self.Loop then
        num = adjust
    end
    if num < 0 then
        num = self.MaxCount
    end
    if num > self.MaxCount then
        num = 0
    end

    self.AcquiredCount = num
    return num
end

function ResourceItem:Increment(count)
    return self:AdjustCount("up", count)
end

function ResourceItem:Decrement(count)
    return self:AdjustCount("down", count)
end
