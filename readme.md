# Schemes.lua

A small Lua53+ library for working with [Schemes](https://github.com/judah-caruso/schemes).


## Usage

```lua
local schemes = require("schemes")

local handle = io.open("my-scheme.svg", "rb")
if not handle then
   -- ...
end

local file = file_handle:read("*a")
handle:close()

local scheme, err = schemes.read_scheme(test_scheme)
if err then
   -- ...
end

print("Opened scheme:", scheme)

-- Apply/work with scheme colors
-- Scheme.c0-c7     : Color
-- Scheme.palette() : [8]Color

print("The hex value of c3 is:", scheme.c3)

print("Exported scheme:\n", schemes.export_scheme(scheme))
```