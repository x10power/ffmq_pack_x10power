CollectableItem = ResourceItem:extend()

--[[
    LeftClick:  Increment
    RightClick: Decrement
]]--
function CollectableItem:init(
    name,
    code,
    maxqty,
    img,
    disabledImg,
    imgMods,
    disabledImgMods,
    minqty
)
    print("CollectableItem:",name)
    ResourceItem.init(
        self,
        name,
        code,
        maxqty,
        img,
        disabledImg,
        imgMods,
        disabledImgMods,
        minqty
    )

    self.AcquiredCount = minqty or 0
    self.SwapActions = true
    self:UpdateBadgeAndIcon()
end