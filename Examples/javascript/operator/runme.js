// Operator overloading example

a = new example.Complex(2,3);
b = new example.Complex(-5,10);

print ("a   =" + a);
print ("b   =" + b);

c = a.plus(b);

print("c   =" + c);
print("a*b =" + a.times(b));
print("a-c =" + a.minus(c));

e = example.Complex.copy(a.minus(c));
print("e   =" + e);

// Big expression
f = a.plus(b).times(c.plus(b.times(e))).plus(a.uminus());
print("f   =" + f);





