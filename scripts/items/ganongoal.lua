local defeatImage = "images/GanonSign.png"
local fastImage = "images/GanonSignFast.png"
local triforceImage = "images/GanonSignTriforce.png"

local overlay = {
  "overlay|images/overlay0.png",
  "overlay|images/overlay1.png",
  "overlay|images/overlay2.png",
  "overlay|images/overlay3.png",
  "overlay|images/overlay4.png",
  "overlay|images/overlay5.png",
  "overlay|images/overlay6.png",
  "overlay|images/overlay7.png",
  "overlay|images/overlayNA.png, @disabled"
}

local overlayAD = "overlay|images/overlayAD.png"
local overlayPED = "overlay|images/overlayPED.png"

GanonGoalItem = class(CustomItem)

function GanonGoalItem:init(name, code)
  self:createItem(name)
  self.code = code
  self:setProperty("active", true)
  self.currentImage = defeatImage
  self.ItemInstance.PotentialIcon = ImageReference:FromPackRelativePath(self.currentImage)
  self.currentOverlay = overlay[8]
  self.goal = 0
  self.count = 8
  self:updateIcon()
end

function GanonGoalItem:canProvideCode(code)
  if code == self.code then
    return true
  else
    return false
  end
end

function GanonGoalItem:providesCode(code)
  if code == self.code then
    return 1
  end
  return 0
end

function GanonGoalItem:onLeftClick()
  if self.goal < 2 then
    if self.count > 0 then
      self.count = self.count - 1
    else
      self.count = 8
    end
    self:updateIcon()
  end
end

function GanonGoalItem:onRightClick()
  if self.goal < 4 then
    self.goal = self.goal + 1
  else
    self.goal = 0
  end
  self:updateIcon()
end

function GanonGoalItem:updateIcon()
  if self.goal == 0 or self.goal == 2 or self.goal == 3 then
    self.currentImage = defeatImage
  elseif self.goal == 1 then
    self.currentImage = fastImage
  else
    self.currentImage = triforceImage
  end
  if self.goal == 4 then
    self.currentOverlay = ""
  elseif self.goal == 3 then
    self.currentOverlay = overlayPED
  elseif self.goal == 2 then
    self.currentOverlay = overlayAD
  elseif self.count == 8 then
    self.currentOverlay = overlay[9]
  else
    self.currentOverlay = overlay[self.count + 1]
  end
  self.ItemInstance.Icon = ImageReference:FromPackRelativePath(self.currentImage, self.currentOverlay)
end

function GanonGoalItem:save()
  local saveData = {
    ["goal"] = self.goal,
    ["count"] = self.count
  }
  return saveData
end

function GanonGoalItem:load(data)
  if data ~= nil then
    self.goal = data["goal"]
    self.count = data["count"]
    self:updateIcon()
  end
  return true
end
