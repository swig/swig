%module xxx

// A string literal is an lvalue of array type, so a 'decltype(auto)' variable initialised by one is a
// reference to an array of characters.  Only whether the literal was wide survives into the parse tree,
// so the character type cannot be recovered and the variable is ignored rather than wrapped, with a
// diagnostic that does not name a type.

decltype(auto) dauto_string = "text";
decltype(auto) dauto_string_wide = L"text";

// Ordinary 'auto' deduces the 'const char *' the array decays to, which is wrapped as usual.
auto auto_string = "text";
