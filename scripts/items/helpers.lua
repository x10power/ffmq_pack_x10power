function myIsPopTracker(version)
  if PopVersion then
    version = version or nil
    
    if version then
      return version == PopVersion
    end

    return true
  end

  return false
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 2 end
  print("{")
  for k, v in pairs(tbl) do
    formatting = string.rep(" ", indent) .. "\"" .. k .. "\": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v) .. ',')
    else
      print(formatting .. v .. ',')
    end
  end
  print("}")
end

function getAmount(code)
  local amount = Tracker:ProviderCountForCode(code)
  amount = math.floor(amount)
  -- print("Get Amount:" .. code .. ":" .. amount)
  return amount
end
function hasAtLeast(code, q)
  local passed = getAmount(code) >= q
  -- print("Has At Least:" .. code .. ':' .. q .. ':' .. (passed and "YES" or "NO"))
  return passed
end
function hasExact(code, q)
  local passed = getAmount(code) == q
  -- print("Has Exact:" .. code .. ':' .. q .. ':' .. (passed and "YES" or "NO"))
  return passed
end
function has(code)
  local passed = hasAtLeast(code, 1)
  -- print("Has:" .. code .. ":" .. (passed and "YES" or "NO"))
  return passed
end

function pazuzuSeven()
  if getAmount("pazuzu") > 0 then
    if has("suncoin") and
      has("dragonclaw") and
      has("axe") then
      if getAmount("pazuzu") <= 3 then
        return true
      end
      if getAmount("pazuzu") >= 4 then
        return has("bomb")
      end
    end
  end

  return false
end
