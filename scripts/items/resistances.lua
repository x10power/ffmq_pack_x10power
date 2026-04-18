ResistanceItem = class(CustomItem)

local resistances = {
    "none",
    "earth","water","fire","air",
    "zombie",
    "axe","bomb","projectile",
    "doom",
    "stone",
    "paralysis","sleep","confusion","poison","blind","silence"
}

function ResistanceItem:ucfirst(input)
    return (input:gsub("^%l", string.upper))
end

function ResistanceItem:getDomain(name)
    local resistType = "resistances"
    local statusTypes = {
        ["blind"] = 1,
        ["confusion"] = 1,
        ["paralysis"] = 1,
        ["poison"] = 1,
        ["silence"] = 1,
        ["sleep"] = 1,
        ["stone"] = 1,
        ["zombie"] = 1
    }
    if statusTypes[name] ~= nil then
        resistType = "statuses"
    end

    return resistType
end

function ResistanceItem:init(name)
    local code = "resist_" .. name
    self:createItem(self:ucfirst(name))
    self.code = {}
    self:setProperty("active", false)
    self:setProperty("target", "none")
    self.code[code] = true

    img = "images/" .. self:getDomain(name) .. "/" .. name .. ".png"
    imgMods = ""
    disabledMods = "@disabled"
    self.activeImage = ImageReference:FromPackRelativePath(
        img,
        imgMods
    )
    self.disabledImage = ImageReference:FromPackRelativePath(
        -- disabledImg or img,
        img,
        disabledMods or imgMods
    )

    self:updateIcon()
end

-- Set state to Active
function ResistanceItem:setActive(active)
    self:setProperty("active", active)
end

-- Get if it's In/Active
function ResistanceItem:getActive()
    return self:getProperty("active")
end

-- Update Icon
function ResistanceItem:updateIcon()
    local target = self:getTarget() or "none"
    local overlay = "images/" ..
        self:getDomain(target) ..
        "/overlay/" ..
        target ..
        ".png"
    if self:getActive() then
        self.ItemInstance.Icon = ImageReference:FromImageReference(
            self.activeImage,
            "overlay|" .. overlay
        )
    else
        self.ItemInstance.Icon = ImageReference:FromImageReference(
            self.disabledImage,
            "overlay|" .. overlay
        )
    end
end

function ResistanceItem:getTarget()
    return self:getProperty("target")
end

function ResistanceItem:setTarget(target)
    self:setProperty("target", target)
end

-- OnLeftClick: Toggle
function ResistanceItem:onLeftClick()
    self:setActive(not self:getActive())
end

-- OnRightClick: Cycle Overlay
function ResistanceItem:onRightClick()
    local target = self:getProperty("target")

    local foundTarget = false
    for _,resist in ipairs(resistances) do
        if target == "silence" then
            foundTarget = true
            resist = "earth"
        end
        if foundTarget then
            self:setTarget(resist)
            self:updateIcon()
            return
        end
        if resist == target then
            foundTarget = true
        end
    end
end

-- True if code is present
function ResistanceItem:canProvideCode(code)
    if self.code[code] then
        return true
    else
        return false
    end
end

-- True if code is present and item is active
function ResistanceItem:providesCode(code)
    if self.code[code] ~= nil and self:getActive() then
        return true
    else
        return false
    end
end

-- Save state
function ResistanceItem:save()
    local saveData = {}
    saveData["active"] = self:getActive()
    saveData["target"] = self:getTarget()
    return saveData
end

-- Load state
function ResistanceItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
    if data["target"] ~= nil then
        self:setTarget(data["target"])
    end
    return true
end

-- Update icon if property is changed
function ResistanceItem:propertyChanged(key, value)
    self:updateIcon()
end

function load_resistances()
    for _,resistance in ipairs(resistances) do
        if resistance ~= "none" then
            ResistanceItem(resistance)
        end
    end
end

load_resistances()
