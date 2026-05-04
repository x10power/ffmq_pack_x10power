ProgressiveItem = CustomItem:extend()

function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

function ProgressiveItem:init(name, codes, stages, initialStage, allowDisabled)
    self:createItem(name)
    self.code = {}
    if type(codes) ~= "table" then
        if codes:find(",") then
            codes = mysplit(codes, ",")
        else
            codes = {codes}
        end
    else
        self.code = codes
    end
    for _,code in ipairs(codes) do
        code = trim(code)
        self.code[code] = code
    end
    self:setProperty("active", allowDisabled ~= nil and (not allowDisabled) or false)
    self:setProperty("allow_disabled", allowDisabled ~= nil and allowDisabled or true)
    self:setProperty("current_stage", initialStage or 1)

    if stages ~= nil then
        self.Stages = {}
        for stageID,thisStage in ipairs(stages) do
            local stage = {}
            stage.id            = stageID
            stage.name          = thisStage["name"]
            stage.code          = {}
            stage.second_code   = {}
            stage.ImgMods       = ""
            if thisStage["codes"] then
                for _,code in ipairs(thisStage["codes"]) do
                    code = trim(code)
                    stage.code[code] = code
                end
            end
            if thisStage["secondary_codes"] then
                for _,code in ipairs(thisStage["secondary_codes"]) do
                    code = trim(code)
                    stage.second_code[code] = code
                end
            end
            if thisStage["img_mods"] then
                stage.ImgMods = thisStage["img_mods"]
            end
            stage.StageImg = ImageReference:FromPackRelativePath(
                thisStage["img"],
                stage.ImgMods
            )
            if stageID == 1 then
                local imgMods = thisStage["img_mods"]
                if (
                    imgMods and
                    imgMods ~= nil and
                    imgMods ~= ""
                ) then
                    imgMods = imgMods .. ",@disabled"
                else
                    imgMods = "@disabled"
                end
                self.disabledImgMods = imgMods
                self.InactiveIcon = ImageReference:FromPackRelativePath(
                    thisStage["img"],
                    self.disabledImgMods
                )
            end
            table.insert(
                self.Stages,
                stage
            )
        end
    end

    self:setStage(self:getStage())
end

-- Set In/Active
function ProgressiveItem:setActive(active)
    self.Active = active
    self:setProperty("active", active)
end
-- Get In/Active
function ProgressiveItem:getActive()
    return self.Active
end

-- Get Code Override
function ProgressiveItem:canProvideCode(code)
    return self.code[code] ~= nil
end
function ProgressiveItem:providesCode(code)
    local base_code = self:canProvideCode(code)
    local current_stage = self.Stages[self.CurrentStage]
    local stage_code = current_stage ~= nil and
        current_stage.code ~= nil and
        current_stage.code[code] ~= nil
    local second_code = current_stage ~= nil and
        current_stage.second_code ~= nil and
        current_stage.second_code[code] ~= nil
    return base_code or stage_code or second_code
end

-- Update Icon
function ProgressiveItem:updateIcon()
    local stageID = self.CurrentStage

    if stageID == -1 then
        self:setActive(false)
        self.ItemInstance.Icon = ImageReference:FromImageReference(
            self.InactiveIcon,
            self.disabledImgMods
        )
    else
        local thisStage = self.Stages[stageID]
        self:setActive(true)
        self.ItemInstance.Icon = ImageReference:FromImageReference(
            self.Stages[stageID].StageImg,
            self.Stages[stageID].ImgMods
        )
    end
end

-- Cycle stage
function ProgressiveItem:setStage(stageID)
    local min = 1
    local max = #self.Stages
    if stageID == -1 and
        self:getProperty("allow_disabled") ~= nil and
        self:getProperty("allow_disabled") then
            stageID = 1
    elseif stageID < min then
        stageID = max
    elseif stageID > max then
        stageID = min
    end

    self:setProperty("current_stage", math.floor(stageID))
    self.CurrentStage = stageID
    self:updateIcon()
end
function ProgressiveItem:getStage()
    return math.floor(self:getProperty("current_stage"))
end
function ProgressiveItem:prevStage()
    self:setStage(self:getStage() - 1)
end
function ProgressiveItem:nextStage()
    self:setStage(self:getStage() + 1)
end

-- LeftClick Override
function ProgressiveItem:onLeftClick()
    self:nextStage()
end
-- RightClick Override
function ProgressiveItem:onRightClick()
    self:prevStage()
end

-- Save Override
function ProgressiveItem:save()
    local saveData = {}
    saveData["active"]          = self:getActive()
    saveData["current_stage"]   = self:getStage()
    return saveData
end
-- Load Override
function ProgressiveItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
    if data["current_stage"] ~= nil then
        self:setStage(data["current_stage"])
    end
end
