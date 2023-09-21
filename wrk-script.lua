-- local uuid = require "resty.jit-uuid"
-- local socket = require("socket")

-- Seed resty.jit-uuid's internal mechanism once
-- uuid.seed()
local urandom = assert(io.open('/dev/urandom','rb'))

local function uuid()

  local a, b, c, d = urandom:read(4):byte(1,4)

  local seed = a*0x1000000 + b*0x10000 + c *0x100 + d
  math.randomseed(seed)

  local random = math.random
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

  local uuid = string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
      return string.format('%x', v)
  end)
  return uuid
end

function setup(thread)

  thread:set("counter", 0)
  thread:set("id", uuid())
  -- print(thread:get("id"))
end

function request()
    local path
    local body = ""
    local cmd = "GET"
    local counter = tonumber(wrk.thread:get("counter"))


    if counter % 3 == 0 then
      wrk.thread:set("id", uuid())
    end

    -- print(wrk.thread:get("id"))
    -- print(counter)
    
    if counter % 3 == 0 then
        cmd = "POST"
        body = '{"data": "string1"}'
        wrk.headers["Content-Type"] = "application/json"
    elseif counter % 3 == 1 then
        cmd = "POST"
        body = '{"data": "string2"}'
        wrk.headers["Content-Type"] = "application/json"
    end

    if cmd == "GET" then
        path = "/" .. wrk.thread:get("id") .. "/query"
    else
        path = "/" .. wrk.thread:get("id") .. "/command"
    end
    
    wrk.thread:set("counter", counter + 1)
    
    return wrk.format(cmd, path, wrk.headers, body)
end
