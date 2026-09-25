%module xxx

// A trailing return type decltype over parameters that no type can be deduced for is ignored.
struct Pt { int x; };
auto parm_pointer(int *p) -> decltype(p + 1) { return p + 1; }
auto parm_member(Pt p) -> decltype(p.x) { return p.x; }

template<class T, class U> auto tmpl_add(T t, U u) -> decltype(t + u) { return t + u; }
%template(tmpl_add) tmpl_add<int, double>;

auto abbrev_mul(auto x, auto y) -> decltype(x * y) { return x * y; }
%template(abbrev_mul) abbrev_mul<int, double>;

// Not ignored: these are deduced from the parameters.
double a, b;
auto shadowed_sum(int a, int b) -> decltype(a + b) { return a + b; }
auto parm_paren(int x) -> decltype((x)) { static int s; s = x; return s; }
auto parm_address(int x) -> decltype(&x) { static int s; s = x; return &s; }
