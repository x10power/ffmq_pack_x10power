ToggleItem = ProgressiveToggleItem:extend()

function ToggleItem:init(
    name,
    codes,
    img,
    imgMods,
    disabledImg,
    disabledMods,
    ignoreUserInput
)

    local stages = {}
    local stage = {
        ["name"] = name,
        ["code"] = codes,
        ["img"] = img,
        ["img_mods"] = imgMods
    }
    table.insert(
        stages,
        stage
    )

    print("ToggleItem:",name)

    ProgressiveToggleItem.init(
        self,
        name,
        codes,
        stages, --*
        1,
        true,
        ignoreUserInput
    )
end

-- RightClick Override
function ToggleItem:onRightClick()
    self:toggle()
end
