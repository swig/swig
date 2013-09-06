// Tests C++ fonctions with STL vectors as arguments

exec("swigtest.start", -1);

// double vectors

// Test of using vector<double> arguments of C++ functions
// Get a vector of double {2.0, 2.0, 2.0, 2.0} from create_double_vector()
dv = create_double_vector(4, 2.0);
if ~exists("dv") | (dv <> [2. 2. 2. 2.]) then swigtesterror(); end
// Get sum this vector elements with sum_double_vector()
ds = sum_double_vector(dv);
if ~exists("ds") | (ds <> 8.) then swigtesterror(); end
// Get a vector of double {5.0, 5.0} from create_double_vector()
dv2 = create_double_vector(2, 5.0);
if ~exists("dv2") | (dv2 <> [5. 5.]) then swigtesterror(); end
// Concat the two vectors with concat_double_vector()
dv3 = concat_double_vector(dv, dv2);
if ~exists("dv3") | (dv3 <> [dv dv2]) then swigtesterror(); end

// integer vectors

// Test of using vector<int> arguments of C++ functions.");
// Get a vector of int {3, 3, 3, 3} from create_integer_vector()
iv = create_integer_vector(3, 3);
if ~exists("iv") | (iv <> int32([3 3 3])) then swigtesterror(); end
// Get the sum of this vector elements with sum_integer_vector()
is = sum_integer_vector(iv);
if ~exists("is") | (is <> int32(9)) then swigtesterror(); end
// Get a vector of int {1, 1} from create_integer_vector()
iv2 = create_integer_vector(2, 1);
// Concat the two vectors with concat_integer_vector()
iv3 = concat_integer_vector(iv, iv2);
if ~exists("iv3") | (iv3 <> int32([iv iv2])) then swigtesterror(); end

// std::string vectors

// Test of using vector<std::string> arguments of C++ functions.
// Get a vector of string {''aa'', ''aa''} with create_string_vector()
sv = create_string_vector(2, "aa");
if ~exists("sv") | (sv <> ["aa"; "aa"]) then swigtesterror(); end
// Get a vector of string {''bb'', ''bb''} with create_string_vector()
sv2 = create_string_vector(2, "bb");
if ~exists("sv2") | (sv2 <> ["bb"; "bb"]) then swigtesterror(); end
// Concat the two vectors with concat_string_vector()
sv3 = concat_string_vector(sv, sv2);
if ~exists("sv3") | (sv3 <> [sv; sv2]) then swigtesterror(); end

// bool vectors

// Test of using vector<bool> arguments of C++ functions.
// Get a vector of bool {true, true} with create_bool_vector()
bv = create_bool_vector(2, %T);
if ~exists("bv") | (bv <> [%T %T]) then swigtesterror(); end
// Get a vector of bool {false, false, false} with create_bool_vector()
bv2 = create_bool_vector(3, %F);
if ~exists("bv2") | (bv2 <> [%F %F %F]) then swigtesterror(); end
// Concat the two vectors with concat_bool_vector()
bv3 = concat_bool_vector(bv, bv2);
if ~exists("bv3") | (bv3 <> [bv bv2]) then swigtesterror(); end

// Pointer (on object) vectors

// Test of using vector of pointers (on object) arguments of C++ functions.
// Get a vector of pointers on object {<classA* a:10>, <classA* a:10>, <classA* a:10>} with create_classAPtr_vector()
classA_1 = new_classA(10);
pv = create_classAPtr_vector(3, classA_1);
if ~exists("pv") | (size(pv) <> 3) | (classA_a_get(pv(1)) <> 10) then swigtesterror(); end
// Get a vector of pointers on object {<classA* a:5>, <classA* a:5>} with create_classAPtr_vector()
classA_2 = new_classA(5);
pv2 = create_classAPtr_vector(2, classA_2);
if ~exists("pv2") | (size(pv2) <> 2) | (classA_a_get(pv2(1)) <> 5) then swigtesterror(); end
// Concat the two vectors with concat_classAPtr_vector()
pv3 = concat_classAPtr_vector(pv, pv2);
if ~exists("pv3") | (size(pv3) <> 5) | (classA_a_get(pv3(1)) <> 10) | (classA_a_get(pv3(4)) <> 5) then swigtesterror(); end

exec("swigtest.quit", -1);

