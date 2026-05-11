ProgressiveItem = ProgressiveToggleItem:extend()

-- LeftClick Override
-- Next Stage (Not a toggle, go forward, move ahead)
function ProgressiveItem:onLeftClick()
    self:nextStage()
end

-- RightClick Override
-- Previous Stage (We're sending you back (to the future))
function ProgressiveItem:onRightClick()
    self:prevStage()
end
