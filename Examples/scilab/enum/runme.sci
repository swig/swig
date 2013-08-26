lines(0);
exec loader.sce;

// Print out the value of some enums
printf("*** color ***\n");
printf("    RED    = %i\n", RED_get());
printf("    BLUE   = %i\n", BLUE_get());
printf("    GREEN  = %i\n", GREEN_get());


printf("\nTesting use of enums with functions\n");

enum_test(RED_get());
enum_test(BLUE_get());
enum_test(GREEN_get());
enum_test(int32(1234));

exit

