ToggleItem = CustomItem:extend()

function trim(s)
    local n = s:find"%S"
    return n and s:match(".*%S", n) or ""
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

-- Initialize Override
function ToggleItem:init(name, codes, img, imgMods, disabledImg, disabledMods, ignoreuserinput)
    self:createItem(name)
    self.name = name
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
    self:setProperty("active", ignoreuserinput or false)
    self:setProperty("ignore_user_input", ignoreuserinput or false)

    if img then
        imgMods = imgMods or ""
        self.ActiveIcon = ImageReference:FromPackRelativePath(
            img,
            imgMods
        )
        if disabledImg == nil then
            disabledImg = img
        end
    end
    if disabledImg then
        if disabledMods == nil then
            if imgMods ~= nil then
                disabledMods = imgMods .. ",@disabled"
            else
                disabledMods = "@disabled"
            end
        end
        self.InactiveIcon = ImageReference:FromPackRelativePath(
            disabledImg or img,
            disabledMods
        )
    end

    self:setActive(self:getProperty("active"))
    self:updateIcon()
end

-- Set In/Active
function ToggleItem:setActive(active)
    self.Active = active
    self:setProperty("active", active)
end
-- Get In/Active
function ToggleItem:getActive()
    return self.Active
end

-- Get Code Override
function ToggleItem:canProvideCode(code)
    return self.code[code] ~= nil
end
function ToggleItem:providesCode(code)
    return self:canProvideCode(code) and self:getActive()
end

-- Update Icon
function ToggleItem:updateIcon()
    if self:getActive() then
        self.ItemInstance.Icon = ImageReference:FromImageReference(self.ActiveIcon)
    else
        self.ItemInstance.Icon = ImageReference:FromImageReference(self.InactiveIcon)
    end
end

-- Toggle
function ToggleItem:toggle()
    if not self:getProperty("ignore_user_input") then
        self:setActive(not self:getActive())
        self:updateIcon()
    end
end

-- LeftClick Override
function ToggleItem:onLeftClick()
    self:toggle()
end
-- RightClick Override
function ToggleItem:onRightClick()
    self:toggle()
end

-- Save Override
function ToggleItem:save()
    local saveData = {}
    saveData["active"] = self:getActive()
    return saveData
end
-- Load Override
function ToggleItem:load(data)
    if data["active"] ~= nil then
        self:setActive(data["active"])
    end
end
