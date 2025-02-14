ProgressiveToggleItem = ProgressiveItem:extend()

-- Update Icon
function ProgressiveToggleItem:updateIcon()
    local stageID = self.CurrentStage

    local thisStage = self.Stages[stageID]
    self.ItemInstance.Icon = ImageReference:FromImageReference(
        self.Stages[stageID].StageImg,
        self:getActive() and "" or "@disabled"
    )
end

function ProgressiveToggleItem:toggle()
    self:setActive(not self:getActive())
    self:updateIcon()
end

function ProgressiveToggleItem:onLeftClick()
    self:toggle()
end

function ProgressiveToggleItem:onRightClick()
    self:nextStage()
end
