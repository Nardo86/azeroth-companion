--
-- base64.lua  -- minimal, dependency-free Base64 encode/decode for Lua 5.1 (WoW).
--
-- Why base64 on the wire?  The addon and the external companion exchange JSON
-- payloads through files (SavedVariables out, a generated .lua file in). Wrapping
-- the JSON in Base64 means neither side has to worry about Lua string escaping,
-- quotes, newlines or non-ASCII bytes: the payload is always a flat [A-Za-z0-9+/=]
-- string that is trivial to embed in Lua and trivial to extract with a regex in
-- Python. Correctness over cleverness.
--

local ADDON, ns = ...

local b64 = {}

local CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- Reverse lookup table (byte value of a base64 char -> 6-bit value).
local DECODE = {}
for i = 1, #CHARS do
  DECODE[CHARS:byte(i)] = i - 1
end

local floor = math.floor
local schar = string.char
local ssub = string.sub
local sbyte = string.byte
local tconcat = table.concat

function b64.encode(data)
  if data == nil then return "" end
  local out = {}
  local n = #data
  local i = 1
  while i <= n do
    local b1 = sbyte(data, i)
    local b2 = sbyte(data, i + 1)
    local b3 = sbyte(data, i + 2)

    local c1 = floor(b1 / 4)                                   -- top 6 bits of b1
    local c2 = (b1 % 4) * 16                                   -- bottom 2 bits of b1 -> top 2 of byte2 group
    local c3, c4

    if b2 then
      c2 = c2 + floor(b2 / 16)
      c3 = (b2 % 16) * 4
      if b3 then
        c3 = c3 + floor(b3 / 64)
        c4 = b3 % 64
      end
    end

    out[#out + 1] = ssub(CHARS, c1 + 1, c1 + 1)
    out[#out + 1] = ssub(CHARS, c2 + 1, c2 + 1)
    out[#out + 1] = c3 and ssub(CHARS, c3 + 1, c3 + 1) or "="
    out[#out + 1] = c4 and ssub(CHARS, c4 + 1, c4 + 1) or "="

    i = i + 3
  end
  return tconcat(out)
end

function b64.decode(data)
  if data == nil then return "" end
  -- Strip anything that is not part of the alphabet (whitespace, newlines...).
  data = data:gsub("[^A-Za-z0-9+/=]", "")
  local out = {}
  local n = #data
  local i = 1
  while i <= n do
    local a = DECODE[sbyte(data, i)]
    local b = DECODE[sbyte(data, i + 1)]
    local cc = ssub(data, i + 2, i + 2)
    local dd = ssub(data, i + 3, i + 3)
    local c = (cc ~= "=" and cc ~= "") and DECODE[sbyte(data, i + 2)] or nil
    local d = (dd ~= "=" and dd ~= "") and DECODE[sbyte(data, i + 3)] or nil

    if a == nil or b == nil then break end

    local n1 = a * 4 + floor(b / 16)                           -- first output byte
    out[#out + 1] = schar(n1)

    if c ~= nil then
      local n2 = (b % 16) * 16 + floor(c / 4)
      out[#out + 1] = schar(n2)
      if d ~= nil then
        local n3 = (c % 4) * 64 + d
        out[#out + 1] = schar(n3)
      end
    end

    i = i + 4
  end
  return tconcat(out)
end

ns.base64 = b64
return b64
