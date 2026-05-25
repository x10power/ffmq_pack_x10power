-- Party Member 2
ProgressiveToggleItem(
    "Party Member 2",
    "party2, pm",
    {
        {
            ["name"] = "Kaeli",
            ["img"] = "images/party/kaeli.gif",
            ["codes"] = "party2, pm1",
            ["second_codes"] = "kaeli"
        },
        {
            ["name"] = "Phoebe",
            ["img"] = "images/party/phoebe.gif",
            ["codes"] = "party2 pm3",
            ["second_codes"] = "phoebe"
        },
        {
            ["name"] = "Reuben",
            ["img"] = "images/party/reuben.gif",
            ["codes"] = "party2, pm4",
            ["second_codes"] = "reuben"
        },
        {
            ["name"] = "Tristam",
            ["img"] = "images/party/tristam.gif",
            ["codes"] = "party2, pm2",
            ["second_codes"] = "tristam"
        }
    }
)

for _,warp in ipairs({
    {   -- FB -> AQ
        ["src"] = "Fireburg",
        ["dest"] = "Aquaria",
        ["code"] = "fbaq",
        ["initialStage"] = 2
    },
    {   -- AQ -> FB
        ["src"] = "Aquaria",
        ["dest"] = "Fireburg",
        ["code"] = "aqfb",
        ["initialStage"] = 2
    },
    {   -- ST -> WT
        ["src"] = "Sealed Temple",
        ["dest"] = "Wintry Temple",
        ["code"] = "stwt",
        ["initialStage"] = 2
    },
    {   -- WT -> ST
        ["src"] = "Wintry Temple",
        ["dest"] = "Sealed Temple",
        ["code"] = "wtst",
        ["initialStage"] = 2
    },
    {   -- FB -> WN
        ["src"] = "Fireburg",
        ["dest"] = "Windia",
        ["code"] = "fbwn",
        ["initialStage"] = 3
    },
    {   -- WN -> FB
        ["src"] = "Windia",
        ["dest"] = "Fireburg",
        ["code"] = "wnfb",
        ["initialStage"] = 3
    },
    {   -- Libra -> Life
        ["src"] = "Libra Temple",
        ["dest"] = "Life Temple",
        ["code"] = "lbtlft",
        ["initialStage"] = 1
    },
    {   -- Life -> Libra
        ["src"] = "Life Temple",
        ["dest"] = "Libra Temple",
        ["code"] = "lftlbt",
        ["initialStage"] = 1
    },
    {   -- Kaidge -> Light
        ["src"] = "Kaidge Temple",
        ["dest"] = "Light Temple",
        ["code"] = "ktlit",
        ["initialStage"] = 3
    },
    {   -- Light -> Kaidge
        ["src"] = "Light Temple",
        ["dest"] = "Kaidge Temple",
        ["code"] = "litkt",
        ["initialStage"] = 3
    },
    {   -- Windia -> Ship
        ["src"] = "Windia",
        ["dest"] = "Ship Dock",
        ["code"] = "wnsd",
        ["initialStage"] = 3
    },
    {
        ["src"] = "Ship Dock",
        ["dest"] = "Windia",
        ["code"] = "sdwn",
        ["initialStage"] = 3
    }
}) do
    local stages = {}
    local codes = warp["code"]
    for _,crest in pairs({"off","libra","gemini","mobius"}) do
        local crestcode = warp["code"] .. "_" .. crest
        local overlay = crest ~= "off"
        local stage = {
            ["name"] = warp["code"]:upper() .. ": " .. ucfirst(crest),
            ["codes"] = crestcode,
            ["img"] = "images/warps/" ..
                warp["src"]:gsub(" Temple",""):gsub(" Dock",""):lower() ..
                "-" ..
                warp["dest"]:gsub(" Temple",""):gsub(" Dock",""):lower() ..
                ".png"
        }
        if not overlay then
            stage["img_mods"] = "@disabled"
        else
            stage["img_mods"] = "overlay|images/warps/overlay/" .. crest .. ".png"
        end
        table.insert(stages, stage)
        codes = codes .. "," .. crestcode
    end
    ProgressiveToggleItem(
        warp["src"] .. " -> " .. warp["dest"],
        codes,
        stages,
        warp["initialStage"] or 0,
        false
    )
end
