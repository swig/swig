lines(0);
exec loader.sce;
SWIG_Init();

// This example shows how to use C++ fonctions with STL vectors arguments
// Here, STL vectors are converted from/to Scilab matrices (SWIG_SCILAB_EXTRA_NATIVE_CONTAINERS is not defined)

// double vectors

disp("Example of passing matrices of double as vector arguments of C++ functions.");
disp("get a vector of double {2.0, 2.0, 2.0, 2.0} from create_double_vector():");
dv = create_double_vector(4, 2.0);
disp(dv);
disp("get the sum of this vector elements with sum_double_vector():")
ds = sum_double_vector(dv);
disp(ds);
dv2 = create_double_vector(2, 5.0);
disp("concat this vector with the vector of double {5.0, 5.0} with concat_double_vector():");
dv3 = concat_double_vector(dv, dv2);
disp(dv3);

// integer vectors

disp("Example of passing matrices of int as vector arguments of C++ functions.");
disp("get a vector of int {3, 3, 3, 3} from create_integer_vector():");
iv = create_integer_vector(3, 3);
disp(iv);
disp("get the sum of this vector elements with sum_integer_vector():")
is = sum_integer_vector(iv);
disp(is);
iv2 = create_integer_vector(2, 1);
disp("concat this vector with the vector of int {1, 1} with concat_integer_vector():");
iv3 = concat_integer_vector(iv, iv2);
disp(iv3);

// string vectors

disp("Example of passing matrices of string as vector arguments of C++ functions.");
disp("get a vector of string {''aa'', ''aa''} with create_string_vector():");
sv = create_string_vector(2, "aa");
disp(sv);
sv2 = create_string_vector(2, "bb");
disp("concat this vector with the vector of string {''bb'', ''bb''} with concat_string_vector():");
sv3 = concat_string_vector(sv, sv2);
disp(sv3);

// bool vectors

disp("Example of passing matrices of bool as vector arguments of C++ functions.");
disp("get a vector of bool {true, true} with create_bool_vector():");
bv = create_bool_vector(2, %T);
disp(bv);
bv2 = create_bool_vector(3, %F);
disp("concat this vector with the vector of bool {false, false, false} with concat_bool_vector():");
bv3 = concat_bool_vector(bv, bv2);
disp(bv3);

// pointer (on object) vectors

disp("Example of passing lists of pointers on object as vector of pointers on objects arguments of C++ functions.");
disp("get a vector of pointers on object {<classA* a:1>, <classA* a:1>, <classA* a:1>} with create_classAPtr_vector():");
pv = create_classAPtr_vector(3, 1);
print_classAPtr_vector(pv);
pv2 = create_classAPtr_vector(2, 5);
disp("concat this vector with the vector of pointers on object {<classA* a:5>, <classA* a:5>} with concat_classAPtr_vector():");
pv3 = concat_classAPtr_vector(pv, pv2);
print_classAPtr_vector(pv3);

exit

