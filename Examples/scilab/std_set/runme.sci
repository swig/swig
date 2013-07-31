exec loader.sce;
SWIG_Init();

// This example shows how to use C++ fonctions with STL sets arguments
// Here, STL sets are converted from/to Scilab matrices (SWIG_SCILAB_EXTRA_NATIVE_CONTAINERS is not defined)

// integer sets

disp("Example of passing matrices of int as set arguments of C++ functions.");
disp("get a set of int {1...4} from create_integer_set():");
is = create_integer_set(1, 4);
disp(is);
disp("get the sum of this set elements with sum_integer_set():")
sum = sum_integer_set(is);
disp(is);
is2 = create_integer_set(3, 6);
disp("concat this set with the set of int {3...6} with concat_integer_set():");
is3 = concat_integer_set(is, is2);
disp(is3);

// string sets

disp("Example of passing matrices of string as set arguments of C++ functions.");
disp("get a set of string {''aa'', ''bb'', ''cc'', ''dd''} with create_string_set():");
ss = create_string_set("aa bb cc dd");
disp(ss);
ss2 = create_string_set("cc dd ee ff");
disp("concat this set with the set of string {''cc'', ''dd'', ''ee'', ''ff''} with concat_string_set():");
ss3 = concat_string_set(ss, ss2);
disp(ss3);

exit

