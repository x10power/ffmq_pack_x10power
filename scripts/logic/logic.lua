-- Component functions.
-- These are not meant to be used directly in the tracker json files.
-- Instead, they are used for the main functions.
function warp_water_fire()
  if Tracker:ProviderCountForCode("geminicrest") > 0
      then return true
      else return false
  end
end

function warp_fire_wind()
  if Tracker:ProviderCountForCode("multikey") > 0 and
      Tracker:ProviderCountForCode("claw1") > 0 and
      Tracker:ProviderCountForCode("mobiuscrest") > 0
      then return true
      else return false
  end
end

-- Main functions.
-- These are meant to be used in "access_rules".
-- Note that these are specifically for WARPING to the locations via crests.
-- This does not check for getting there the normal way (via coin).
-- This is to make it easier if you wish to have a spot show up as yellow if reachable only via crest warps, green if reachable normally.
function warp_water()
  if (Tracker:ProviderCountForCode("rivercoin") > 0 and warp_water_fire()) or
      (Tracker:ProviderCountForCode("suncoin") > 0 and warp_fire_wind() and warp_water_fire())
      then return true
      else return false
  end
end

function warp_fire()
  if (Tracker:ProviderCountForCode("sandcoin") > 0 and warp_water_fire()) or
      (Tracker:ProviderCountForCode("suncoin") > 0 and warp_fire_wind())
      then return true
      else return false
  end
end

function warp_wind()
  if (Tracker:ProviderCountForCode("sandcoin") > 0 and warp_water_fire() and warp_fire_wind()) or
      (Tracker:ProviderCountForCode("rivercoin") > 0 and warp_fire_wind())
      then return true
      else return false
  end
end

-- As an example of how to use the main functions, for accessing the fire area:

-- Without these scripts:
-- "access_rules": [ "rivercoin", "sandcoin,geminicrest", "suncoin,multikey,claw,mobiuscrest" ]

-- With these scripts:
-- "access_rules": [ "rivercoin", "$warp_fire" ]

function aquaria_expert_access()
    return (
        (has("rivercoin") or fireburg_expert_access()) and
        has("geminicrest") --gemini warp
    )
end

function fireburg_expert_access()
    return (
        (
            has("suncoin") and
            has("mobiuscrest") and
            has("multikey") and
            has("claw")
        ) or --windia teleport to locked house
        (
            has("sandcoin") and
            has("geminicrest")
        )--aquaria warp
    )
end

function fireburg_access()
    return (
        has("rivercoin") or fireburg_expert_access()
    )
end

function windia_expert_access()
    return (
        fireburg_access() and
        has("mobiuscrest") and
        has("multikey") and
        has("claw") --fireburg locked house teleport
    )
end

function doom_castle_access()
    return (
        has("suncoin") and
        has("mobiuscrest") and
        has("thunderrock") and
        has("captainscap") and
        has("megagrenade")
    )
end

function doom_castle_expert_access()
    return (
        windia_expert_access() and
        has("mobiuscrest") and
        has("thunderrock") and
        has("captainscap") and
        has("megagrenade")
    )
end
