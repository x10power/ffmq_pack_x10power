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
    if has("suncoin") and has("dragonclaw") and has("axe") then
      if getAmount("pazuzu") <= 3 then
        return true
      end
      if getAmount("pazuzu") >= 4 then
        return has("bombs")
      end
    end
  end
end
