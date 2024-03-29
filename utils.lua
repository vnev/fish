local class = require "middleclass"

local Utils = class("Utils")

function Utils:copyarr_shallow(orig)
    local orig_type = type(orig)
    local co
    if orig_type == 'table' then
        co = {}
        for orig_key, orig_value in pairs(orig) do
            co[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        co = orig
    end

    return co
end

return Utils
