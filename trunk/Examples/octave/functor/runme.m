# Operator overloading example
example

a = example.intSum(0);
b = example.doubleSum(100.0);

# Use the objects.  They should be callable just like a normal
# python function.

for i=0:100-1,
    a(i);           # Note: function call
    b(sqrt(i));     # Note: function call
endfor

a.result()
b.result()


