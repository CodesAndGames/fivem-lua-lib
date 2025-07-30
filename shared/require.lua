
-- side detection
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

local modules = {}

-- load a lua resource file as module (for a specific side)
-- rsc: resource name
-- path: lua file path without extension
function module(rsc, path)
  if not path then -- shortcut for vrp, can omit the resource parameter
    path = rsc
    rsc = "jd-library"
  end
  local key = rsc.."/"..path
  local rets = modules[key]
  if rets then -- cached module
    return table.unpack(rets, 2, rets.n)
  else
    local code = LoadResourceFile(rsc, path..".lua")
    if code then
      local f, err = load(code, rsc.."/"..path..".lua")
      if f then
        local rets = table.pack(xpcall(f, debug.traceback))
        if rets[1] then
          modules[key] = rets
          return table.unpack(rets, 2, rets.n)
        else
          error("error loading module "..rsc.."/"..path..": "..rets[2])
        end
      else
        error("error parsing module "..rsc.."/"..path..": "..err)
      end
    else
      error("resource file "..rsc.."/"..path..".lua not found")
    end
  end
end