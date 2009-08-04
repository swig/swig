// builder the *.so
exec example_builder.sce;

// loader the *.so
exec loader.sce;

exec example.sce;

// Print out the value of some enums
printf("*** color ***\n");
printf("    RED    = %i\n", color.RED);
printf("    BLUE   = %i\n", color.BLUE);
printf("    GREEN  = %i\n", color.GREEN);


printf("\nTesting use of enums with functions\n");

enum_test(color.RED);
enum_test(color.BLUE);
enum_test(color.GREEN);
enum_test(1234);

exit

