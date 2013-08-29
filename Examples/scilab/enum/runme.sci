lines(0);
exec loader.sce;
SWIG_Init();

// Print out the value of some enums
printf("*** color ***\n");
printf("    RED    = %i\n", RED);
printf("    BLUE   = %i\n", BLUE);
printf("    GREEN  = %i\n", GREEN);


printf("\nTesting use of enums with functions\n");

enum_test(RED);
enum_test(BLUE);
enum_test(GREEN);
enum_test(int32(1234));

exit

