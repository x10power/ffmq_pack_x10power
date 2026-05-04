ProgressiveToggleItem = ProgressiveItem:extend()

-- Update Icon
function ProgressiveToggleItem:updateIcon()
    local stageID = self.CurrentStage

    local thisStage = self.Stages[stageID]
    local theseMods = self.Stages[stageID].ImgMods
    if not self:getActive() then
        if theseMods and theseMods ~= nil and theseMods ~= "" then
            theseMods = theseMods .. ","
        end
        theseMods = theseMods .. "@disabled"
    end
    self.ItemInstance.Icon = ImageReference:FromImageReference(
        self.Stages[stageID].StageImg,
        theseMods
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
