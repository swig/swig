# Operator overloading example
import example

a = example.Complex(2, 3)
b = example.Complex(-5, 10)

print("a   = %s" % a)
print("b   = %s" % b)

c = a + b
print("c   = %s" % c)
print("a*b = %s" % (a * b))
print("a-c = %s" % (a - c))

e = example.ComplexCopy(a - c)
print("e   = %s" % e)

# Big expression
f = ((a + b) * (c + b * e)) + (-a)
print("f   = %s" % f)
