%module xxx

// A trailing return type decltype over parameters that no type can be deduced for is ignored.
struct Pt { int x; };
auto parm_pointer(int *p) -> decltype(p + 1) { return p + 1; }
auto parm_member(Pt p) -> decltype(p.x) { return p.x; }

template<class T, class U> auto tmpl_add(T t, U u) -> decltype(t + u) { return t + u; }
%template(tmpl_add) tmpl_add<int, double>;

auto abbrev_mul(auto x, auto y) -> decltype(x * y) { return x * y; }
%template(abbrev_mul) abbrev_mul<int, double>;

// Also when only the text skipped in a subscript, the arguments of a call or an operand that is not parsed names one.
struct Arr { int m[3]; };
Arr arr;
int overloaded(int);
int overloaded(double);
int counter;
auto parm_index(int i) -> decltype(arr.m[i]) { return arr.m[i]; }
auto parm_argument(int i) -> decltype(overloaded(i)) { return overloaded(i); }
auto parm_unparsed(int i) -> decltype(counter = i) { return counter = i; }

// Not ignored: these are deduced from the parameters.
double a, b;
auto shadowed_sum(int a, int b) -> decltype(a + b) { return a + b; }
auto parm_paren(int x) -> decltype((x)) { static int s; s = x; return s; }
auto parm_address(int x) -> decltype(&x) { static int s; s = x; return &s; }

// Not ignored, though not deduced: the 'x' after '.' is a member, not the parameter.
Pt pt;
auto member_not_parm(int x) -> decltype(arr.m[pt.x]) { return arr.m[pt.x] + x; }
