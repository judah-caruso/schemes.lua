local schemes = {
   _version       = "1.0.0",
   _default_title = "Color Scheme by Person",
   _template      = [[
<svg width="288px" height="140px" xmlns="http://www.w3.org/2000/svg" baseProfile="full" version="1.1">
   <title>%s</title>
   <style>
      #c0 { fill: %s; } <!-- Background -->
      #c1 { fill: %s; } <!-- Foreground, Operators --> 
      #c2 { fill: %s; } <!-- Types --> 
      #c3 { fill: %s; } <!-- Procedures, Keywords --> 
      #c4 { fill: %s; } <!-- Constants, Strings -->
      #c5 { fill: %s; } <!-- Pre-Processor, Special -->
      #c6 { fill: %s; } <!-- Errors -->
      #c7 { fill: %s; } <!-- Comments --> 
   </style>

   <rect width="288" height="140" id="c0"></rect>   
   <text x="10" y="20" style="font-family: monospace" id="c1"><tspan x="10"><tspan id="c3">function</tspan> <tspan id="c3">main</tspan>()</tspan><tspan x="25" dy="1em" id="c7">-- This is a comment</tspan><tspan x="25" dy="1em"><tspan id="c2">local</tspan> point = { x = <tspan id="c4">10</tspan>, y = <tspan id="c4">20</tspan> }</tspan><tspan x="25" dy="1em"><tspan id="c3">if</tspan> point.x &lt;= <tspan id="c4">10</tspan> <tspan id="c3">then</tspan></tspan><tspan x="40" dy="1em">print <tspan id="c4">"Hello, World"</tspan></tspan><tspan x="25" dy="1em" id="c3">end</tspan><tspan x="10" dy="1em" id="c3">end</tspan><tspan x="10" dy="2em">main()</tspan>
   </text>
</svg>]]
}

-- Internal utilities

local math_min     = math.min
local math_max     = math.max
local math_abs     = math.abs
local math_ceil    = math.ceil
local table_insert = table.insert
local table_concat = table.concat
local string_find  = string.find
local string_match = string.match
local string_sub   = string.sub
local fmt          = string.format

local clamp = function(v, min, max)
   return math_min(math_max(v, min), max)
end

local trim = function(str)
   local from = string_match(str, "^%s*()")
   return from > #str and "" or string_match(str, ".*%S", from)
end

local contains = function(str, substr)
   return string_find(str, substr) ~= nil
end

-- Creates a new Scheme table containing the title and colors of the scheme
function Scheme(title)
   return setmetatable({
      title = title == nil and schemes._default_title or trim(title),
      c0    = Color(0, 0, 0),
      c1    = Color(0, 0, 0),
      c2    = Color(0, 0, 0),
      c3    = Color(0, 0, 0),
      c4    = Color(0, 0, 0),
      c5    = Color(0, 0, 0),
      c6    = Color(0, 0, 0),
      c7    = Color(0, 0, 0),

      -- Returns the colors of the scheme as an array
      palette = function(me)
         return {
            me.c0,
            me.c1,
            me.c2,
            me.c3,
            me.c4,
            me.c5,
            me.c6,
            me.c7
         }
      end,
   }, {
      __tostring = function(me)
         return ("%s [ %s %s %s %s %s %s %s %s ]"):format(
            me.title,
            me.c0,
            me.c1,
            me.c2,
            me.c3,
            me.c4,
            me.c5,
            me.c6,
            me.c7
         )
      end,
   })
end

-- Creates a new Color table containing the color values [r, g, b] in the range
-- of [0, 255] and methods for converting from RGB to Hex, Decimal, and [3]number.
function Color(r, g, b)
   return setmetatable({
      r = clamp(r == nil and 0 or r, 0, 255),
      g = clamp(g == nil and 0 or g, 0, 255),
      b = clamp(b == nil and 0 or b, 0, 255),

      rgb = function(me)
         return (me.r << 16) | (me.g << 8) | me.b
      end,

      -- Returns an array containing the [r, g, b] values of the color
      values = function(me)
         return { me.r, me.g, me.b }
      end,

      -- Returns the hex representation of the color
      hex = function(me)
         return ("#%06X"):format(me:rgb())
      end,
   }, {
      __tostring = function(me)
         return me:hex()
      end,
   })
end

-- Parses an SVG scheme string into a Scheme table
-- Returns:
--    Scheme (parsed scheme), string (error message, nil if successful)
function schemes.read_scheme(source)
   local title  = string_match(source, "<title>(.*)</title>")
   local scheme = Scheme(title)

   local style_element = string_match(source, "<style>(.*)</style>")
   for id in style_element:gmatch("#(c[0-9])") do
      -- Ignore IDs we don't care about
      if  id ~= "c0"
      and id ~= "c1"
      and id ~= "c2"
      and id ~= "c3"
      and id ~= "c4"
      and id ~= "c5"
      and id ~= "c6"
      and id ~= "c7" then
         goto continue
      end

      local id_start = string_find(style_element, id)

      local fill_start, fill_end = string_find(style_element, "fill%s*[:]", id_start)
      if fill_start == nil or fill_end == nil then
         return nil, fmt("Unable to find 'fill' property for '%s'", id)
      end

      local color_end = string_find(style_element, ";", fill_end)
      if color_end == nil then
         return nil, fmt("Invalid 'fill' color for %s", id)
      end

      local color = string_sub(style_element, fill_end + 1, color_end -  1)
      color = trim(color)

      local err = nil

      if contains(color, "rgb") then
         scheme[id], err = schemes.color_from_rgb_str(color)
         if err then return nil, err end
      elseif contains(color, "hsv") then
         scheme[id], err = schemes.color_from_hsv_str(color)
         if err then return nil, err end
      elseif contains(color, "#")   then
         scheme[id], err = schemes.color_from_hex_str(color)
         if err then return nil, err end
      else
         return nil, fmt("Unknown color format '%s' for %s", color, id)
      end

      ::continue::
   end

   return scheme, nil
end

-- Converts a Scheme table into a valid SVG scheme string
-- Returns:
--    string (SVG Scheme)
function schemes.export_scheme(scheme)
   return schemes._template:format(
      scheme.title,
      scheme.c0,
      scheme.c1,
      scheme.c2,
      scheme.c3,
      scheme.c4,
      scheme.c5,
      scheme.c6,
      scheme.c7
   )
end

-- Converts a hex string (in the format of #RRGGBB) to a Color
-- Returns:
--    Color, string (error message, nil if successful)
function schemes.color_from_hex_str(str)
   if type(str) ~= "string" then
      return nil, fmt("Expected color to be a string, instead was %s", type(str))
   end

   local fixed = str:gsub("#", "0x")
   local color = tonumber(fixed)

   return Color(
      (color & 0xFF0000) >> 16,
      (color & 0x00FF00) >> 8,
      (color & 0x0000FF)
   ), nil
end

-- Converts an RGB string (in the format of rgb(RR, GG, BB)) to a Color
-- Returns:
--    Color, string (error message, nil if successful)
function schemes.color_from_rgb_str(str)
   if type(str) ~= "string" then
      return nil, fmt("Expected color to be a string, instead was %s", type(str))
   end

   local r, g, b = string_match(str, "(%d+)[,%s]*(%d+)[,%s]*(%d+)")
   if r == nil or g == nil or b == nil then
      return nil, fmt("Invalid color '%s'", str)
   end

   return Color(
      tonumber(r),
      tonumber(g),
      tonumber(b)
   ), nil
end

-- Converts an HSV string (in the format of hsv(HH, SS, VV)) to a Color
-- Returns:
--    Color, string (error message, nil if successful)
function schemes.color_from_hsv_str(str)
   if type(str) ~= "string" then
      return nil, fmt("Expected color to be a string, instead was %s", type(str))
   end

   local h, s, v = string_match(str, "(%d+)[,%s°%%]*(%d+)[,%s%%]*(%d+)[%%]*")
   if h == nil or s == nil or v == nil then
      return nil, fmt("Invalid color '%s'", str)
   end

   local fract = function(x)       return x - math.floor(x) end
   local lerp  = function(a, b, t) return a + (b - a) * t   end

   local hue = clamp(tonumber(h), 0, 360) / 360
   local sat = clamp(tonumber(s), 0, 100) / 100
   local val = clamp(tonumber(v), 0, 100) / 100

   local r, g, b = (function(hue, sat, val)
      local px = clamp(math_abs(fract(hue + 1)       * 6 - 3) - 1, 0, 1)
      local py = clamp(math_abs(fract(hue + 2 / 3.0) * 6 - 3) - 1, 0, 1)
      local pz = clamp(math_abs(fract(hue + 1 / 3.0) * 6 - 3) - 1, 0, 1)

      px = lerp(1, px, sat)
      py = lerp(1, py, sat)
      pz = lerp(1, pz, sat)

      return val * px, val * py, val * pz
   end)(hue, sat, val)

   return Color(
      math_ceil(r * 255),
      math_ceil(g * 255),
      math_ceil(b * 255)
   ), nil
end

return schemes
