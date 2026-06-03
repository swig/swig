-- file: runme.lua

-- This file illustrates class C++ interface generated
-- by SWIG.

---- importing ----
require('example')

ex = example

-- Calling a module function ( aka global function )
assert( ex.module_function() == 7 )
print("example.module_function(): ", ex.module_function())

-- Accessing a module (aka global) variable
assert( ex.module_variable == 9 )
print("example.module_variable: ", ex.module_variable)

-- Creating an instance of the class
w1 = ex.MyWorld.World()
print("Creating class instance: w1 = ex.MyWorld.World(): ", w1)

-- Accessing class members
assert( ex.MyWorld.World():create_world() == 17 )
print( "w1:create_world() = ", w1:create_world() )
assert( w1:create_world() == 17 )
print( "w1:world_max_count = ", w1.world_max_count )
assert( w1.world_max_count == 9 )

-- Accessing enums from class within namespace
print( "Accessing enums: ex.MyWorld.Nested.Dweller.MALE = ", ex.MyWorld.Nested.Dweller.MALE )
assert( ex.MyWorld.Nested.Dweller.MALE == 0 )
print( "Accessing enums: ex.MyWorld.Nested.Dweller.FEMALE = ", ex.MyWorld.Nested.Dweller.FEMALE )
assert( ex.MyWorld.Nested.Dweller.FEMALE == 1 )

-- Accessing static member function
print( "Accessing static member function: ex.MyWorld.Nested.Dweller.count() = ", ex.MyWorld.Nested.Dweller.count() )
assert( ex.MyWorld.Nested.Dweller.count() == 19 )

