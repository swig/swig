// Operator overloading example


a = new example.intSum(0);
b = new example.doubleSum(100.0);

// Use the objects.  They should be callable just like a normal
// javascript function.

for (i=1;i<=100;i++) 
    a.call(i);                // Note: function call
    b.call(Math.sqrt(i));     // Note: function call

print(a.result());
print(b.result());

