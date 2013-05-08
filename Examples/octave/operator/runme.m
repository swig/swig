# Operator overloading example
swigexample

a = swigexample.ComplexVal(2,3);
b = swigexample.ComplexVal(-5,10);

printf("a   = %s\n",disp(a));
printf("b   = %s\n",disp(b));

c = a + b;
printf("c   = %s\n",disp(c));
printf("a*b = %s\n",disp(a*b));
printf("a-c = %s\n",disp(a-c));

e = swigexample.ComplexVal(a-c);
printf("e   = %s\n",disp(e));

# Big expression
f = ((a+b)*(c+b*e)) + (-a);
printf("f   = %s\n",disp(f));

# paren overloading
printf("a(3)= %s\n",disp(a(3)));

# friend operator
printf("2*a = %s\n",disp(2*a));
