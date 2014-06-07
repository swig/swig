-- file: runme.lua

-- This file illustrates runtime class manipulation

---- importing ----
if string.sub(_VERSION,1,7)=='Lua 5.0' then
	-- lua5.0 doesnt have a nice way to do this
	lib=loadlib('luametaclass.dll','luaopen_luametaclass') or loadlib('luametaclass.so','luaopen_luametaclass')
	assert(lib)()
else
	-- lua 5.1 does
	require('luametaclass')
end

----- Object creation -----

lm = luametaclass

e1 = lm.EmptyClass()

m1 = lm.SWIG_Lua_metaclass(e1)
m2 = lm.SWIG_Lua_metaclass(lm.EmptyClass)

function mem1( self, arg1 ) return arg1 + 2 end

assert( m1.class_cname == m2.class_cname )

-- print("Class name: ", m1.class_cname) -- TODO: REMOVE

-- Manipulations with member functions

mf = m1:getFunctions()

mf.mem1 = mem1
assert( e1:mem1(5) == 7 )

-- inheritance also works
d1 = lm.Derived()
assert( d1:mem1(7) == 9 )

-- Add member variable
pseudo_static_x = 5

function get_x(self) return pseudo_static_x end

function set_x(self,new_x)
    pseudo_static_x = new_x
end

m1:setMemberVariable("x", get_x, set_x)

assert(e1.x == pseudo_static_x)

e1.x = 7
assert(pseudo_static_x == 7)
assert(e1.x == 7)

-- Disable setter
m1:setMemberVariable("x", get_x)

assert(e1.x == 7)

function assign( target, index, value )
    target[index] = value
end

succeeded = pcall( assign, e1, "x", 9 )
assert( not succeeded )
assert( pseudo_static_x == 7 )

-- Remove variable
m1:removeMemberVariable("x")

assert( e1.x == nil )

