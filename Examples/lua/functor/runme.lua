-- Operator overloading example
require('example')

a = example.intSum(0)
b = example.doubleSum(100.0)

-- Use the objects.  They should be callable just like a normal
-- lua function.

for i=0,100 do
    a(i)                -- Note: function call
    b(math.sqrt(i))     -- Note: function call
end
print("int sum 0..100 is",a:result(),"(expected 5050)")
print("double sum 0..100 is",b:result(),"(expected ~771.46)")

