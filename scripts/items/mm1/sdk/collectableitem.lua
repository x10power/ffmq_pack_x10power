CollectableItem = ConsumableItem:extend()
CollectableItem.Loop = true

function CollectableItem:init(name, code, maxqty, img, disabledImg, imgMods, disabledImgMods, minqty)
    maxqty = maxqty or self.MaxCount

    self:createItem(name)
    self.code = code

    self.MaxCount = maxqty
    self.imgMods = ""
    self.disabledImgMods = ""
    if img then
        if imgMods and imgMods ~= nil and imgMods ~= "" then
            self.imgMods = imgMods
        end
        self.FullIcon = ImageReference:FromPackRelativePath(img, self.imgMods)
        if disabledImg == nil then
            disabledImg = img
        end
    end

    if disabledImgMods == nil then
        if self.imgMods ~= "" then
            disabledImgMods = self.imgMods .. ",@disabled"
        else
            disabledImgMods = "@disabled"
        end
    end

    self.disabledImgMods = disabledImgMods

    if disabledImg then
        self.EmptyIcon = ImageReference:FromPackRelativePath(disabledImg, self.disabledImgMods)
    end

    self.SwapActions = true
    self.AcquiredCount = minqty or 0

    self:UpdateBadgeAndIcon()
end

function CollectableItem:AdjustCount(direction, count)
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

function CollectableItem:Increment(count)
    return self:AdjustCount("up", count)
end

function CollectableItem:Decrement(count)
    return self:AdjustCount("down", count)
end
