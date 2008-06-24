# Operator overloading example
example

a = example.ComplexVal(2,3);
b = example.ComplexVal(-5,10);

printf("a   = %s\n",a);
printf("b   = %s\n",b);

c = a + b;
printf("c   = %s\n",c);
printf("a*b = %s\n",a*b);
printf("a-c = %s\n",a-c);

e = example.ComplexVal(a-c);
printf("e   = %s\n",e);

# Big expression
f = ((a+b)*(c+b*e)) + (-a);
printf("f   = %s\n",f);

# paren overloading
printf("a(3)= %s\n",a(3));

