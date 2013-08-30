lines(0);
exec loader.sce;
SWIG_Init();

printf("\nTesting use of enums wrapped as Scilab functions\n");

printf("*** color ***\n");
printf("    RED    = %i\n", RED_get());
printf("    BLUE   = %i\n", BLUE_get());
printf("    GREEN  = %i\n", GREEN_get());

enum_test(RED_get());
enum_test(BLUE_get());
enum_test(GREEN_get());
enum_test(int32(1234));

printf("\nTesting use of enums wrapped as Scilab variables\n");

printf("*** fruit ***\n");
printf("    APPLE   = %i\n", APPLE);
printf("    ORANGE  = %i\n", ORANGE);
printf("    LEMON   = %i\n", LEMON);

scilabconst_enum_test(APPLE);
scilabconst_enum_test(ORANGE);
scilabconst_enum_test(LEMON);
scilabconst_enum_test(int32(1234));

exit
