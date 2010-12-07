# file: runme.m

example

# ----- Object creation -----

# Print out the value of some enums
printf("*** color ***\n");
printf("    RED    = %i\n", example.RED);
printf("    BLUE   = %i\n", example.BLUE);
printf("    GREEN  = %i\n", example.GREEN);

printf("\n*** Foo::speed ***\n");
printf("    Foo_IMPULSE   = %i\n", example.Foo_IMPULSE);
printf("    Foo_WARP      = %i\n", example.Foo_WARP);
printf("    Foo_LUDICROUS = %i\n", example.Foo_LUDICROUS);

printf("\nTesting use of enums with functions\n");

example.enum_test(example.RED, example.Foo_IMPULSE);
example.enum_test(example.BLUE,  example.Foo_WARP);
example.enum_test(example.GREEN, example.Foo_LUDICROUS);
example.enum_test(1234,5678)

printf("\nTesting use of enum with class method\n");
f = example.Foo();

f.enum_test(example.Foo_IMPULSE);
f.enum_test(example.Foo_WARP);
f.enum_test(example.Foo_LUDICROUS);


