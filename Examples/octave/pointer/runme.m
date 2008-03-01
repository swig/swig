# file: runme.m

example;

# First create some objects using the pointer library.
printf("Testing the pointer library\n");
a = example.new_intp();
b = example.new_intp();
c = example.new_intp();
example.intp_assign(a,37);
example.intp_assign(b,42);

a,b,c

# Call the add() function with some pointers
example.add(a,b,c);

# Now get the result
r = example.intp_value(c);
printf("     37 + 42 = %i\n",r);

# Clean up the pointers
example.delete_intp(a);
example.delete_intp(b);
example.delete_intp(c);

# Now try the typemap library
# This should be much easier. Now how it is no longer
# necessary to manufacture pointers.

printf("Trying the typemap library\n");
r = example.sub(37,42);
printf("     37 - 42 = %i\n",r);

# Now try the version with multiple return values

printf("Testing multiple return values\n");
[q,r] = example.divide(42,37);
printf("     42/37 = %d remainder %d\n",q,r);



