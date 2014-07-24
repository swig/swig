lines(0);
ilib_verbose(0);
exec loader.sce;
example_Init();

printf("\nTest %%scilab_const(1) feature: constants and enums are wrapped as Scilab variables\n");

printf("\nTest enums\n");
printf("*** color ***\n");
printf("    RED    = %i\n", RED);
printf("    BLUE   = %i\n", BLUE);
printf("    GREEN  = %i\n", GREEN);

printf("\n*** Foo::speed ***\n")
printf("    Foo_IMPULSE   = %i\n", Foo_IMPULSE);
printf("    Foo_WARP      = %i\n", Foo_WARP);
printf("    Foo_LUDICROUS = %i\n", Foo_LUDICROUS);

printf("\nTest enums as argument of functions\n");

enum_test(RED, Foo_IMPULSE);
enum_test(BLUE, Foo_WARP);
enum_test(GREEN, Foo_LUDICROUS);
enum_test(1234, 5678);

printf("\nTest enums as argument of class methods\n");

f = new_Foo();
Foo_enum_test(f, Foo_IMPULSE);
Foo_enum_test(f, Foo_WARP);
Foo_enum_test(f, Foo_LUDICROUS);
delete_Foo(f);

printf("\nTest constants\n");

printf("ICONST  = %i (should be 42)\n", ICONST);
printf("FCONST  = %5.4f (should be 2.1828)\n", FCONST);
printf("SCONST  = ''%s'' (should be ''Hello World'')\n", SCONST);
printf("EXPR    = %5.4f (should be 48.5484)\n", EXPR);
printf("iconst  = %i (should be 37)\n", iconst);
printf("fconst  = %3.2f (should be 42.20)\n", fconst);

exit
