CollectableItem = ConsumableItem:extend()
CollectableItem.Loop = true

function CollectableItem:init(name, code, maxqty, img, disabledImg, imgMods, disabledImgMods, minqty)
    maxqty = maxqty or self.MaxCount

    self:createItem(name)
    self.code = code

    self.MaxCount = maxqty
    if img then
        self.FullIcon = ImageReference:FromPackRelativePath(img, imgMods or "")
        if disabledImg == nil then
            disabledImg = img
        end
    end
    if disabledImgMods == nil then
        if imgMods ~= nil then
            disabledImgMods = "@disabled," .. imgMods
        else
            disabledImgMods = "@disabled"
        end
    end
    if disabledImg then
        self.EmptyIcon = ImageReference:FromPackRelativePath(disabledImg, disabledImgMods or "")
    end

    self.SwapActions = true
    self.AcquiredCount = minqty or 0
    print(minqty,maxqty)

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
