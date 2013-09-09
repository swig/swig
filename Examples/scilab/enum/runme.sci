lines(0);
ilib_verbose(0);
exec loader.sce;
SWIG_Init();

printf("\nTesting use of enums (wrapped as Scilab variables)\n");

printf("*** color ***\n");
printf("    RED    = %i\n", RED);
printf("    BLUE   = %i\n", BLUE);
printf("    GREEN  = %i\n", GREEN);

enum_test(RED);
enum_test(BLUE);
enum_test(GREEN);
enum_test(int32(1234));

exit
