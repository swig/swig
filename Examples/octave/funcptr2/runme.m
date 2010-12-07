# file: runme.m

example 

a = 37
b = 42

# Now call our C function with a bunch of callbacks

printf("Trying some C callback functions\n");
printf("    a        = %i\n", a);
printf("    b        = %i\n", b);
printf("    ADD(a,b) = %i\n", example.do_op(a,b,example.ADD));
printf("    SUB(a,b) = %i\n", example.do_op(a,b,example.SUB));
printf("    MUL(a,b) = %i\n", example.do_op(a,b,example.MUL));

printf("Here is what the C callback function objects look like in Octave\n");
example.ADD
example.SUB
example.MUL

printf("Call the functions directly...\n");
printf("    add(a,b) = %i\n", example.add(a,b));
printf("    sub(a,b) = %i\n", example.sub(a,b));
