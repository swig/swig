local v=require("cpp11_template_templated_methods")

-- assign test
local ov = v.OctetVector()
local o = v.octet(111)
ov:push_back(o)
local sc = v.SimpleContainer(ov)
local orlv = v.OctetResourceLimitedVector(0) -- TODO miss octet constructor default parameter
orlv:assign(sc:begin_renamed(), sc:end_renamed())
local collection = orlv:getCollection()
assert(collection:size() == 1, "wrong size")
local oo = collection[0]
assert(oo.num == 111, "wrong val")

-- assign_and_append test
ov = v.OctetVector()
o = v.octet(222)
ov:push_back(o)
sc = v.SimpleContainer(ov)
orlv = v.OctetResourceLimitedVector(0) -- TODO miss octet constructor default parameter
local final_octet = v.octet(333)
orlv:assign_and_append(sc:begin_renamed(), sc:end_renamed(), final_octet)
collection = orlv:getCollection()
assert(collection:size() == 2, "wrong size")
oo = collection[0]
assert(oo.num == 222, "wrong val")
oo = collection[1]
assert(oo.num == 333, "wrong finalval")

-- container_from_iterators test
ov = v.OctetVector()
o = v.octet(987)
ov:push_back(o)
sc = v.SimpleContainer(ov)
collection = v.OctetResourceLimitedVector.container_from_iterators(sc:begin_renamed(), sc:end_renamed())
assert(collection:size() == 1, "wrong collection size")
oo = collection[0]
assert(oo.num == 987, "wrong collection val")

-- emplace_back test
ov = v.OctetVector()
o = v.octet(222)
ov:push_back(o)
sc = v.SimpleContainer(ov)
orlv = v.OctetResourceLimitedVector(0) -- TODO miss octet constructor default parameter
-- TODO we get extra element in orlv
final_octet = v.octet(444)
orlv:emplace_back(final_octet)
orlv:emplace_back()
orlv:emplace_back(555)
collection = orlv:getCollection()
assert(collection:size() == 4, "wrong size") -- TODO Should be 3?
oo = collection[0] -- TODO Seems inserted before first_index?
assert(oo.num == 0, "wrong value -1")
local first_index = 1 -- TODO first index was 0
oo = collection[first_index]
assert(oo.num == 444, "wrong value 0")
oo = collection[first_index + 1]
assert(oo.num == 0, "wrong value 1")
oo = collection[first_index + 2]
assert(oo.num == 555, "wrong value 2")

-- Variadic templated constructor in template
orlv = v.OctetResourceLimitedVector(999)
o = v.octet(888)
local orlv2 = v.OctetResourceLimitedVector(o)

-- Variadic static templated method in template
collection = v.OctetResourceLimitedVector.make_collection()
assert(collection:size() == 0, "wrong make value 1111")

collection = v.OctetResourceLimitedVector.make_collection(1111)
oo = collection[0]
assert(oo.num == 1111, "wrong make value 1111")

o = v.octet(2222)
collection = v.OctetResourceLimitedVector.make_collection(o)
oo = collection[0]
assert(oo.num == 2222, "wrong make value 2222")
