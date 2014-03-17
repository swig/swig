// Tests C++ fonctions with STL sets as arguments

exec("swigtest.start", -1);

// integer sets

// Example of passing matrices of int as set arguments of C++ functions.");
// get a set of int {1...4} from create_integer_set():");
iset = create_integer_set(1, 4);
if ~exists("iset") | ~isequal(iset, [1 2 3 4]) then swigtesterror(); end
// get the sum of this set elements with sum_integer_set():")
isum = sum_integer_set(int32(iset));
if ~exists("isum") | (isum <> 10) then swigtesterror(); end
// get a set of of int {3...6} from create_integer_set():");
iset2 = create_integer_set(3, 6);
if ~exists("iset2") | ~isequal(iset2, [3 4 5 6]) then swigtesterror(); end
// concat the two sets with concat_integer_set():");
iset3 = concat_integer_set(int32(iset), int32(iset2));
if ~exists("iset3") | ~isequal(iset3, [1 2 3 4 5 6]) then swigtesterror(); end

// string sets

// Example of passing matrices of string as set arguments of C++ functions.");
// get a set of string {''aa'', ''bb'', ''cc'', ''dd''} with create_string_set():");
sset = create_string_set("aa bb cc dd");
if ~exists("sset") | ~isequal(sset, ["aa" "bb" "cc" "dd"]) then swigtesterror(); end
// get a set of string {''cc'', ''dd'', ''ee'', ''ff''} with create_string_set():");
sset2 = create_string_set("cc dd ee ff");
if ~exists("sset2") | ~isequal(sset2, ["cc" "dd" "ee" "ff"]) then swigtesterror(); end
// concat the two sets with concat_string_set():");
sset3 = concat_string_set(sset, sset2);
if ~exists("sset3") | ~isequal(sset3, ["aa" "bb" "cc" "dd" "ee" "ff"]) then swigtesterror(); end

exec("swigtest.quit", -1);

