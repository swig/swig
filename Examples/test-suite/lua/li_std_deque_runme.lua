local v=require("li_std_deque")

-- Test constructors for std::deque<int>
local intDeque  = v.IntDeque()
local intDeque2 = v.IntDeque(3)
local intDeque3 = v.IntDeque(4, 42)
local intDeque4 = v.IntDeque(intDeque3)

-- Test constructors for std::deque<double>
local doubleDeque  = v.DoubleDeque()
local doubleDeque2 = v.DoubleDeque(3)
local doubleDeque3 = v.DoubleDeque(4, 42.5)
local doubleDeque4 = v.DoubleDeque(doubleDeque3)

-- Test constructors for std::deque<Real>
local realDeque  = v.RealDeque()
local realDeque2 = v.RealDeque(3)
local realDeque3 = v.RealDeque(4, 42.5)
local realDeque4 = v.RealDeque(realDeque3)

-- average() should return the average of all values in a std::deque<int>
intDeque:push_back(2)
intDeque:push_back(4)
intDeque:push_back(6)
local avg = v.average(intDeque)
assert(avg == 4)
assert(intDeque:size() == 3)

-- half() should return a std::deque<float>, where each element is half
-- the value of the corresponding element in the input deque<float>.
-- The original deque's contents are unchanged.
realDeque:clear()
realDeque:push_back(5.5)
local halfDeque = v.half(realDeque)
assert(halfDeque:getitem(0) == 2.75)
assert(realDeque:size() == 1)

-- halve_in_place() should...
v.halve_in_place(doubleDeque4)
assert(doubleDeque4:getitem(0) == 21.25)
assert(doubleDeque4:getitem(1) == 21.25)
assert(doubleDeque4:getitem(2) == 21.25)
assert(doubleDeque4:getitem(3) == 21.25)
assert(doubleDeque4:size() == 4)
