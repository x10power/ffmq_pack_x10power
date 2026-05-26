ProgressiveToggleItem = CustomItem:extend()

function setDefault(obj, propName, value, default)
    if value ~= nil then
        obj:setProperty(propName, value)
    else
        obj:setProperty(propName, default)
    end
end

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

--[[

self = {
  name:              Human-readable name
  code:              code hash, k,v:code,code
  active:            Active?
  allow_disabled:    Can it be off?
  current_stage:     Initialize stage ID
  ignore_user_input: Noclip?
  icons: {
    base: {
      on:  Active   { fname: filename, mods: IconMods }
      off: Inactive { fname: filename, mods: IconMods }
    }
    stages: [
      {
        fname: filename
        mods:  IconMods
        id: stage ID number
        code: code hash, k,v:code,code
        second_code: code hash, k,v:code,code
      }
    ]
  }
}

-- All
self:init()           : Constructor
self:canProvideCode() : Built-in override; code is this item?
self:providesCode()   : Built-in override; active for code?
self:updateIcon()     : Update display
self:onLeftClick()    : LClick
self:onRightClick()   : RClick
self:save()           : Built-in override; Save Properties
self:load()           : Built-in override; Load Properties

-- Toggle
self:setActive()      : Write In/Active
self:getActive()      : Read In/Active
self:toggle()         : Toggle In/Active

-- Progressive
self:setStage()       : Write Stage ID
self:getStage()       : Read Stage ID
self:prevStage()      : Update to previous stage
self:nextStage()      : Update to next stage

]]--

function ProgressiveToggleItem:init(
    name,
    codes,
    stages,
    initialStage,
    allowDisabled,
    ignoreUserInput
)
    -- print("ProgressiveToggleItem:",name)

    -- create base item
    self:createItem(name)
    self.name = name

    -- build codes
    self.code = {}
    if type(codes) ~= "table" then
        if codes:find(",") then
            codes = mysplit(codes, ",")
        else
            codes = {codes}
        end
    end
    for _,code in ipairs(codes) do
        code = trim(code)
        self.code[code] = code
    end

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

    -- set allow_disabled; default true
    setDefault(self, "allow_disabled", allowDisabled, true)
    -- set active; default !allow_disabled
    self:setActive(not self:getProperty("allow_disabled"))
    -- set current stage; default 1
    setDefault(self, "current_stage", initialStage, 1)
    setDefault(self, "initial_stage", initialStage, 1)
    -- ignore user input; default false
    setDefault(self, "ignore_user_input", ignoreUserInput, false)

    -- build stages
    if stages ~= nil then
        self.stages = {}
        -- cycle through stages
        for stageID,thisStage in ipairs(stages) do
            local stage = {}
            -- id
            stage.id = stageID
            -- name
            stage.name = thisStage["name"]
            -- build codes
            stage.code = {}
            if thisStage["codes"] then
                for _,code in ipairs(thisStage["codes"]) do
                    code = trim(code)
                    stage.code[code] = code
                end
            end
            -- build secondary codes
            stage.second_code = {}
            if thisStage["secondary_codes"] then
                for _,code in ipairs(thisStage["secondary_codes"]) do
                    code = trim(code)
                    stage.second_code[code] = code
                end
            end
            -- icon
            stage.icon = {}
            stage.icon.fname = thisStage["img"]
            stage.icon.mods = thisStage["img_mods"] or ""
            -- stage.icon.obj = self:setIcon(
            --     stage.icon.fname,
            --     stage.icon.mods
            -- )

            -- set disabled image
            if stageID == 1 then
                local imgMods = stage.icon.mods or ""
                if (not imgMods:find("@disabled")) and (self:getProperty("allow_disabled")) then
                    if imgMods ~= nil and imgMods ~= "" then
                        imgMods = imgMods .. ","
                    end
                    imgMods = imgMods .. "@disabled"
                end

                self.icons.base.off = {
                    ["fname"] = thisStage["img"],
                    ["mods"] = imgMods
                }
                -- self.icons.base.off.obj = self:setIcon(
                --     self.icons.base.off.fname,
                --     self.icons.base.off.mods
                -- )
            end

            -- add compiled stage
            table.insert(
                self.stages,
                stage
            )
        end
    end

    self:setProperty("initialized", false)

    self:updateIcon()
end

-- Set In/Active
function ProgressiveToggleItem:setActive(active)
    self.Active = active
    self:setProperty("active", active)
end

-- Get In/Active
function ProgressiveToggleItem:getActive()
    return self:getProperty("active")
end

-- Get Code Override
function ProgressiveToggleItem:canProvideCode(code)
    return self.code[code] ~= nil
end

-- Get Active Code
function ProgressiveToggleItem:providesCode(code)
    local base_code = self:canProvideCode(code)
    local current_stage = self.stages[self.CurrentStage]
    local stage_code = current_stage ~= nil and
        current_stage.code ~= nil and
        current_stage.code[code] ~= nil
    local second_code = current_stage ~= nil and
        current_stage.second_code ~= nil and
        current_stage.second_code[code] ~= nil
    return base_code or stage_code or second_code
end

-- Set Icon
function ProgressiveToggleItem:setIcon(fname, mods)
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

-- Update Icon
function ProgressiveToggleItem:updateIcon()
    local initVal = self:getProperty("initialized")
    if initVal ~= true then
        -- set stage
        self:setProperty("initialized", true)
        self:setStage(self:getStage())
    end

    local stageID = self.CurrentStage
    local thisStage = self.stages[stageID]

    local setActive = self.Active

    if setActive then
        self:setActive(setActive)
        self:setIcon(
            thisStage.icon.fname,
            thisStage.icon.mods
        )
    else
        self:setActive(setActive)
        self:setIcon(
            thisStage.icon.fname,
            thisStage.icon.mods .. "," .. self.icons.base.off.mods
        )
    end
end

-- Set Stage ID
function ProgressiveToggleItem:setStage(stageID)
    local min = 1
    if (self:getProperty("initial_stage")) then
        min = self:getProperty("initial_stage")
    end
    local max = #self.stages
    local newStage = stageID
    if stageID < min then
        newStage = max
    elseif stageID > max then
        newStage = min
    end

    -- print("Staging " .. self.name .. " to ",min,stageID,newStage,max)

    self:setProperty("current_stage", math.floor(newStage))
    self.CurrentStage = newStage
    self:updateIcon()
end

-- Get Stage ID
function ProgressiveToggleItem:getStage()
    return math.floor(self:getProperty("current_stage"))
end

-- Toggle
function ProgressiveToggleItem:toggle()
    self:setActive(not self:getActive())
    self:updateIcon()
end

-- Progressive
function ProgressiveToggleItem:prevStage()
    self:setStage(self.CurrentStage - 1)
end

function ProgressiveToggleItem:nextStage()
    self:setStage(self.CurrentStage + 1)
end

-- Mouse Handlers
function ProgressiveToggleItem:onLeftClick()
    self:toggle()
end

function ProgressiveToggleItem:onRightClick()
    self:nextStage()
end
