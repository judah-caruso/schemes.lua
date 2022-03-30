local schemes = require("schemes")

local test_scheme =
[[
   <svg width="288px" height="140px" xmlns="http://www.w3.org/2000/svg" baseProfile="full" version="1.1">
   <title>Color Scheme by Person</title>
   <style>
      #c0 { fill: hsv(0%, 0%, 14%); } <!-- Background -->
      #c1 { fill: #ADBAC7; } <!-- Foreground, Operators --> 
      #c2 { fill: rgb(244, 112, 103); } <!-- Types --> 
      #c3 { fill: #DCBDFB; } <!-- Procedures, Keywords --> 
      #c4 { fill: #96D0FF; } <!-- Constants, Strings -->
      #c5 { fill: hsv(4°, 58%, 96%); } <!-- Pre-Processor, Special -->
      #c6 { fill: #F69D50; } <!-- Errors -->
      #c7 { fill: #768390; } <!-- Comments --> 
   </style>

   <rect width="288" height="140" id="c0"></rect>   
   <text x="10" y="20" style="font-family: monospace" id="c1"><tspan x="10" id="c5">#[derive(Debug)]</tspan><tspan x="10" dy="1em"><tspan id="c2">struct</tspan> Point {</tspan><tspan x="25" dy="1em">x: <tspan id="c2">f32</tspan>,</tspan><tspan x="25" dy="1em">y: <tspan id="c2">f32</tspan>,</tspan><tspan x="10" dy="1em">}</tspan><tspan x="10" dy="1em"><tspan id="c2">fn</tspan> <tspan id="c3">main</tspan>() {</tspan><tspan x="25" dy="1em"><tspan id="c2">let</tspan> point = Point{ <tspan id="c4">10</tspan>, <tspan id="c4">20</tspan> };</tspan><tspan x="25" dy="1em">println!(<tspan id="c4">"{:?}"</tspan>, point);</tspan><tspan x="10" dy="1em">} <tspan id="c7">// This is a comment</tspan></tspan></text>
   </svg>
]]

local scheme, err = schemes.read_scheme(test_scheme)
if err then
   print("Unable to read scheme:", err)
   return
end

print("Opened scheme:", scheme)

-- Apply/work with scheme colors
-- Scheme.c0-c7     : Color
-- Scheme.palette() : [8]Color

print("The hex value of c3 is:", scheme.c3)

print("Exported scheme:\n", schemes.export_scheme(scheme))

