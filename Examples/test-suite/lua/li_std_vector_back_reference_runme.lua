li = require("li_std_vector_back_reference")

function first_element()
    local v = li.VectorWheel()
    v:push_back(li.Wheel(11))
    v:push_back(li.Wheel(22))
    -- v will be deleted after exit from this method
    return v[0]
end

local size = first_element().size
assert(size == 11, "Back reference not working " .. size)
