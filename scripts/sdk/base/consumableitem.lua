ConsumableItem = CustomItem:extend()
ConsumableItem:set {
    FullIcon = ImageReference:FromPackRelativePath("images/0058.png"),
    EmptyIcon = ImageReference:FromPackRelativePath("images/0059.png"),
    MaxCount = {
        value = 0x7fffffff,
        afterSet = function(self)
                self.AcquiredCount = self.AcquiredCount
                self.ConsumedCount = self.ConsumedCount
                self:UpdateBadgeAndIcon()
            end
    },
    MinCount = {
        value = 0,
        afterSet = function(self)
                self.AcquiredCount = self.AcquiredCount
                self.ConsumedCount = self.ConsumedCount
                self:UpdateBadgeAndIcon()
            end
    },
    AcquiredCount = {
        value = 0x7fffffff,
        set = function(self, value) return math.min(math.max(math.max(value, self.ConsumedCount), self.MinCount), self.MaxCount) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    ConsumedCount = {
        value = 0,
        set = function(self, value) return math.max(math.min(value, self.AvailableCount), 0) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    AvailableCount = {
        get = function(self) return self.AcquiredCount - self.ConsumedCount end
    },
    DisplayFractionOfMax = {
        value = false,
        afterSet = function(self) self:UpdateBadgeAndIcon() end
    },
    CountIncrement = 1,
    SwapActions = false
}

function ConsumableItem:init(name, code, maxqty, img, disabledImg, imgMods, disabledImgMods)
    maxqty = maxqty or self.MaxCount

    self:createItem(name)
    self.code = code

    self.MaxCount = maxqty
    self.imgMods = ""
    if img then
        if imgMods and imgMods ~= nil and imgMods ~= "" then
            self.imgMods = imgMods
        end
        self.FullIcon = ImageReference:FromPackRelativePath(img, self.imgMods)
        if disabledImg == nil then
            disabledImg = img
        end
        if disabledImgMods == nil then
            disabledImgMods = "@disabled," .. self.ImgMods
        end
        self.disabledImgMods = disabledImgMods or "@disabled"
        self.EmptyIcon = ImageReference:FromPackRelativePath(disabledImg, self.disabledImgMods)
    end
    self:UpdateBadgeAndIcon()
end

function ConsumableItem:UpdateBadgeAndIcon()
    -- If there's no more to get
    if self.AvailableCount == 0 then
        -- If we've got any, use Full icon
        -- If we don't have any, use Empty icon
        if self.AcquiredCount > 0 then
            self.ItemInstance.Icon = self.FullIcon
            if myIsPopTracker() then
                self.ItemInstance.Icon = ImageReference:FromImageReference(
                    self.FullIcon,
                    self.imgMods
                )
            end
        else
            self.ItemInstance.Icon = self.EmptyIcon
            if myIsPopTracker() then
                self.ItemInstance.Icon = ImageReference:FromImageReference(
                    self.EmptyIcon,
                    self.disabledImgMods
                )
            end
        end
        self.ItemInstance.BadgeText = myIsPopTracker() and "" or nil
    else
        -- If there's more to get
        -- Use Full icon
        self.ItemInstance.Icon = self.FullIcon
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

function ConsumableItem:InvalidateAccessibility()
    if myIsPopTracker() then
        return
    end
    self.ItemInstance:InvalidateAccessibility()
end

function ConsumableItem:Increment(count)
    count = count or 1
    local num = math.min(self.MaxCount, math.max(self.MinCount, self.AcquiredCount + (self.CountIncrement * count)))
    self.AcquiredCount = num
    return num
end

function ConsumableItem:Decrement(count)
    count = count or 1
    local num = math.min(self.MaxCount, math.max(self.MinCount, self.AcquiredCount - (self.CountIncrement * count)))
    self.AcquiredCount = num
    return num
end

function ConsumableItem:Consume(quantity)
    quantity = quantity or 1
    if self.AvailableCount < quantity then
        return false
    end
    self.ConsumedCount = self.ConsumedCount + quantity
    return true
end

function ConsumableItem:Release(quantity)
    quantity = quantity or 1
    if self.ConsumedCount < quantity then
        return false
    end
    self.ConsumedCount = self.ConsumedCount - quantity
    return true
end

function ConsumableItem:onLeftClick()
    if self.SwapActions then
        self:Increment(1)
    else
        self:Decrement(1)
    end
end

function ConsumableItem:onRightClick()
    if self.SwapActions then
        self:Decrement(1)
    else
        self:Increment(1)
    end
end

function ConsumableItem:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function ConsumableItem:providesCode(code)
    if code == self.code then
        return self.AcquiredCount
    end
    return 0
end

function ConsumableItem:advanceToCode(code)
    if code == nil or code == self.code then
        self:onLeftClick()
    end
end

function ConsumableItem:save()
    local data = {}
    data["min_count"] = self.MinCount
    data["max_count"] = self.MaxCount
    data["consumed_count"] = self.ConsumedCount
    data["acquired_count"] = self.AcquiredCount
    return data
end

function ConsumableItem:load(data)
    local num = -1
    local num2 = -1
    if data["acquired_count"] ~= nil then
        num = data["acquired_count"]
    end
    if data["consumed_count"] ~= nil then
        num2 = data["consumed_count"]
    end
    if num < 0 or num2 < 0 then
        return false
    end
    if data["max_count"] ~= nil then
        self.MaxCount = data["max_count"]
    end
    if data["min_count"] ~= nil then
        self.MinCount = data["min_count"]
    end
    self.AcquiredCount = num
    self.ConsumedCount = num2
    return true
end
