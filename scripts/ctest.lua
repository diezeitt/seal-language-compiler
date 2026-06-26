#!/bin/lua
local target_file = arg[1]

if not target_file then
     print("Missing Argument.")
     os.exit()
end

local file_convert = target_file:gsub("%..-$", "") .. ".c"
local file_read = io.open(target_file,"r")
local file_write = io.open(file_convert, "w")
local scope = 0
local c_dec_types = { "short", "int", "long", "long long" }

for line in file_read:lines() do
    --Multiple line comment
    line = line:gsub("/~", "/*")
    line = line:gsub("~/", "*/")
    --Single line check
    if not (line:find("/%*") or line:find("%*/")) then
        line = line:gsub("~", "//")
    end
    --function check
    if line:find("#")and line:find("%(") and line:find("%)") then
        line = line:gsub("^%s*#%s*i%d+%s+", "int ")
    elseif line:find("#") then
        line = ""
    end
    --i to [c_dec_types] conversion
    line = line:gsub("%f[%w]i(%d+)%f[%W]", function(i_var)

        local i = tonumber(i_var)

        if i >= 1 and i <= 8 then
            return "short"
        elseif i >= 9 and i <= 32 then
            return "int"
        elseif i >= 33 and i <= 64 then
            return "long"
        else
            return "long long"
        end
    end)
    --Jump to if (condition given)
    line = line:gsub("%f[%w]jump%s*(%b())%s*([%w_]+);", "if %1 goto %2;")
    --Jump to if (no condition)
    line = line:gsub("%f[%w]jump%s+([%w_]+);", "goto %1;")
    -- :mirror to mirror:
    line = line:gsub(":([%w_]+)", "%1:")

    local brace_open  = line:find("{")
    local brace_close = line:find("}")
    --bracket check
    if scope == 0 and not brace_open and not line:find("%[") then
        for _, c_dec in ipairs(c_dec_types) do
            if line:find("%f[%w]" .. c_dec .. "%f[%W]") and line:find(";") and not line:find("=") then
                line = line:gsub(";", " = 0;")
                break
            end
        end
    end

    if brace_open then scope = scope + 1 end
    if brace_close then scope = scope - 1 end
    file_write:write(line .. "\n")
end

file_read:close()
file_write:close()
print(file_convert)
