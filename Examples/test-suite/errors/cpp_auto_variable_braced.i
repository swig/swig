%module xxx

// Diagnostics for copy-list-initialisation of an 'auto' variable.  The declaration is parsed and the variable
// ignored, because a braced initialiser list deduces a 'std::initializer_list', which SWIG declares only as a
// stub that warns rather than wrapping.  The warning does not name that type: three of the declarations below
// deduce nothing at all and are not valid C++.

int g = 7;

auto good_list = {1, 2, 3};

// Every declarator of the declaration shares the one placeholder, so the whole declaration is ignored.
auto multi_a = {1}, multi_b = {2};

// Ill-formed C++: there is nothing to deduce the element type from.
auto empty_list = {};

// Ill-formed C++: the elements deduce different element types.
auto mixed_list = {1, 2.0};

// Ill-formed C++: copy-list-initialisation of a 'decltype(auto)' variable is not allowed.
decltype(auto) dauto_list = {1, 2};

// Direct-list-initialisation of a single element is deduced rather than ignored, so this is wrapped as an int.
auto braced_int{1};

int after = 8;
