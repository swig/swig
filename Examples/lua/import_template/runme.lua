-- Test various properties of classes defined in separate modules

print("Testing the %import directive with templates")

require 'base'
require 'foo'
require 'bar'
require 'spam'

-- Create some objects

print("Creating some objects")

local a = base.IntBase()
local b = foo.IntFoo()
local c = bar.IntBar()
local d = spam.IntSpam()

-- Try calling some methods
print("Testing some methods\n")
print("Should see 'Base::A' ---> " .. a:A())
print("Should see 'Base::B' ---> " .. a:B())

print("Should see 'Foo::A' ---> " .. b:A())
print("Should see 'Foo::B' ---> " .. b:B())

print("Should see 'Bar::A' ---> " .. c:A())
print("Should see 'Bar::B' ---> " .. c:B())

print("Should see 'Spam::A' ---> " .. d:A())
print("Should see 'Spam::B' ---> " .. d:B())

-- Try some casts

print("\nTesting some casts\n\n")

local x = a:toBase()
print("Should see 'Base::A' ---> " .. x:A())
print("Should see 'Base::B' ---> " .. x:B())

x = b:toBase()
print("Should see 'Foo::A' ---> " .. x:A())
print("Should see 'Base::B' ---> " .. x:B())

x = c:toBase()
print("Should see 'Bar::A' ---> " .. x:A())
print("Should see 'Base::B' ---> " .. x:B())

x = d:toBase()
print("Should see 'Spam::A' ---> " .. x:A())
print("Should see 'Base::B' ---> " .. x:B())

x = d:toBar()
print("Should see 'Bar::B' ---> " .. x:B())

print("\nTesting some dynamic casts\n")
x = d:toBase()


print(" Spam -> Base -> Foo : ")
local y = foo.IntFoo.fromBase(x)
if y ~= nil then
      print("bad swig")
else
      print("good swig")
end

print(" Spam -> Base -> Bar : ")
y = bar.IntBar.fromBase(x)
if y ~= nil then
      print("good swig")
else
      print("bad swig")
end

print(" Spam -> Base -> Spam : ")
y = spam.IntSpam.fromBase(x)
if y ~= nil then
      print("good swig")
else
      print("bad swig")
end

print(" Foo -> Spam : ")
y = spam.IntSpam.fromBase(b)
if y ~= nil then
      print("bad swig")
else
      print("good swig")
end
