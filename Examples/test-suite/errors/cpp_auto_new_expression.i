%module xxx

%immutable;

// An 'auto' variable initialised by a new-expression SWIG cannot deduce a type from: one that is part of a larger
// expression, one with a parenthesised type-id, and one with a placeholder in the type-id that is not plain 'auto'.
auto after_initialiser = new int(5) + 0;
auto after_type_id = new int[3] + 1;
auto parenthesised = new (int *[3]);
auto constrained = new Numeric auto(5);
auto placeholder = new decltype(auto)(1);

// No warning where the variable has a type of its own, or for a default argument.
int *declared = new int[3] + 1;
int *declared_constrained = new Numeric auto(5);
void take(int *p = new int[3] + 1, int *q = new (int *[3]), int *r = new Numeric auto(5));
