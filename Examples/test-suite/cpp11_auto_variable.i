%module cpp11_auto_variable

%ignore func();

%inline %{

static auto t = true;
static constexpr auto f = false;

static auto zero = 0;
static constexpr auto one = 1;

// Cv-qualified auto, either ordering.
static const auto cz = 2;
static auto const zc = 3;

static auto la = 1.0L;
static auto da = 1.0;
static auto fa = 1.0f;
static constexpr auto lc = 1.0L;
static constexpr auto dc = 1.0;
static constexpr auto fc = 1.0f;

static constexpr auto pi_approx = 355. / 133;

static constexpr auto Bar = "foo";
static constexpr auto Foo = "bar";

static constexpr auto Bar2 = Bar;
static constexpr auto Foo2 = Foo;

static auto Bar3 = f ? zero : t;
static constexpr auto Foo3 = f ? f : one;

int func() { return 1; }
static constexpr auto NOEXCEPT_FUNC = noexcept(func);

%}

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ptr_t;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ptr_zero;

%inline %{
static auto ptr_t = &t;                    // bool *
static constexpr auto ptr_f = &f;          // const bool *
static auto ptr_zero = &zero;              // int *
static constexpr auto ptr_one = &one;      // const int *
static const auto const_ptr_zero = &zero;  // int *const
%}

%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) cast_constcharptr;

%{
static unsigned char bytes[] = "abc";
%}

%inline %{
static auto cast_double = static_cast<double>(one);
static auto cast_uint = static_cast<unsigned int>(one);
static auto cast_constcharptr = reinterpret_cast<const char *>(bytes);
%}

// A cast to char * is not deduced: both char * and const char * are described by the same
// type code, which names the const form, so deducing it would add a const the cast never had.
%warnfilter(SWIGWARN_CPP11_AUTO) cast_charptr;

%inline %{
static auto cast_charptr = reinterpret_cast<char *>(bytes);
%}

// SWIG can't deduce the type from a function call.
// Test two approaches to suppressing the warning.
%ignore Bad1;
%warnfilter(SWIGWARN_CPP11_AUTO) Bad2;

// The name of a function is not something a variable's type can be deduced from either.
%warnfilter(SWIGWARN_CPP11_AUTO) Bad3;

%inline %{
static auto Bad1 = func();
static auto Bad2 = func();
static auto Bad3 = func;
%}
%{
// Wunused-variable warning suppression
bool warning_suppression() {
  return Bad1 != 0 || Bad2 != 0 || Bad3 != 0 || cast_charptr != 0;
}
%}


// Parentheses around the initialiser do not change what an 'auto' variable deduces.

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_nested_ptr;

%inline %{
static auto paren_int = (1);
static auto paren_double = (da);
static auto paren_ptr = (&zero);       // int *
static auto paren_nested_ptr = ((ptr_zero));  // int *
static auto paren_nested = ((one));
%}

// A C-style cast deduces the type it casts to, and a dereference the type pointed to.

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) zero_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) cstyle_cast_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) cstyle_cast_null;

%inline %{
static int *zero_ptr = &zero;
static auto cstyle_cast_ptr = (const int *)zero_ptr;  // const int *
static auto cstyle_cast_null = ((int *)0);            // int *
static auto cstyle_cast_double = (double)zero;        // double
static auto pointer_condition = zero_ptr ? 2 : 3;     // int
static auto pointer_compare = zero_ptr != 0;          // bool
static auto dereferenced = *zero_ptr;                 // int
static auto dereferenced_cast = *(int *)zero_ptr + 1; // int
static int deref_const_int_ptr(const int *p) { return *p; }
%}

// A typedef does not stop the top level const being dropped or an array decaying, and is kept when it hides neither.

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) typedef_array;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) typedef_array_ptr;

%inline %{
typedef const int ConstInt;
typedef int IntArray3[3];
typedef int IntAlias;
static ConstInt const_int_value = 4;
static IntArray3 int_array3 = {5, 6, 7};
static IntAlias int_alias_value = 8;
static auto typedef_const = const_int_value;  // int
static auto typedef_array = int_array3;       // int *
static auto *typedef_array_ptr = int_array3;  // int *
static auto typedef_alias = int_alias_value;  // IntAlias
static int int_ptr_second(const int *p) { return p[1]; }
%}

// A subscript deduces the element type, and the return type of the one operator[] a class declares.

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) subscript_pointer;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) matrix_row;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) element_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) forwarded_element;
%ignore AutoIndexed::operator[];

%inline %{
struct AutoIndexed {
  double values[2];
  double operator[](int i) const { return values[i]; }
};
static AutoIndexed auto_indexed = {{1.5, 2.5}};
static int subscript_array[3] = {30, 31, 32};
static int *subscript_pointer = subscript_array;
static int subscript_matrix[2][3] = {{40, 41, 42}, {43, 44, 45}};
static auto array_element = subscript_array[1];                     // int
static auto pointer_element = subscript_pointer[2];                 // int
static auto matrix_row = subscript_matrix[1];                       // int *
static auto matrix_element = subscript_matrix[1][2];                // int
static auto typedef_array_element = int_array3[2];                  // int
static auto paren_element = (subscript_pointer)[0];                 // int
static auto literal_element = "abc"[1];                             // char
static auto indexed_element = auto_indexed[1];                      // double
static auto &element_ref = subscript_array[0];                      // int &
static auto &&forwarded_element = subscript_array[2];               // int &
static void set_subscript_array_value(int i, int v) { subscript_array[i] = v; }
static int matrix_default(int v = subscript_matrix[0][1]) { return v; }
%}

// auto drops a reference that a typedef hides, as the 'reference' member typedef of a container does.

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) int_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) typedef_ref_address;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) typedef_ref_forwarded;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ref_indexed_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) typedef_ref_paren_class;
%ignore RefIndexed::operator[];

%inline %{
template<class T> struct RefIndexed {
  typedef T &reference;
  T values[2];
  reference operator[](int i) { return values[i]; }
};
typedef int &IntRef;
%}
%template(RefIndexedInt) RefIndexed<int>;
%inline %{
static RefIndexed<int> ref_indexed = {{70, 71}};
static IntRef int_ref = ref_indexed.values[0];
static auto typedef_ref_element = ref_indexed[1];      // int
static auto *typedef_ref_address = &ref_indexed[0];    // int *
static auto &&typedef_ref_forwarded = ref_indexed[1];  // int &
static auto typedef_ref_copy = int_ref;                // int

// decltype of a parenthesised name keeps the one reference a typedef hides.
typedef RefIndexed<int> &RefIndexedRef;
static RefIndexedRef ref_indexed_ref = ref_indexed;
static decltype((int_ref)) typedef_ref_paren = int_ref;                        // int &
static decltype((ref_indexed_ref)) typedef_ref_paren_class = ref_indexed_ref;  // RefIndexed<int> &
%}

%inline %{
// Concatenation of a literal with an encoding prefix and one without
// was added in C++11.
static auto wstring_lit_len1 = sizeof(L"123" "456") / sizeof(wchar_t) - 1;
static auto wstring_lit_len2 = sizeof("123" L"456") / sizeof(wchar_t) - 1;
%}

%inline %{
// A unary '+' or '-' applies the integral promotion, so every integral type narrower
// than int deduces int.
static short short_value = 1;
static unsigned short ushort_value = 1;
static char char_value = 1;
static bool bool_value = true;

static auto promoted_short = +short_value;
static auto promoted_ushort = +ushort_value;
static auto negated_short = -short_value;
static auto promoted_char = +char_value;
static auto promoted_bool = +bool_value;
%}

// A functional cast to a class, or a typedef of one, deduces the class.
%{
struct AutoForward { int f; };
%}
struct AutoForward;
%inline %{
struct AutoPoint { int x; int y; };
struct AutoConv { AutoConv(int v) : v(v) {} int v; };
typedef AutoPoint AutoPointAlias;
namespace AutoSpace { struct Inner { int i; }; }
template<class T> struct AutoBox { T t; };
%}
%template(AutoBoxInt) AutoBox<int>;
%inline %{
static auto class_brace = AutoPoint{1, 2};              // AutoPoint
static auto class_paren = AutoConv(3);                  // AutoConv
static auto class_empty = AutoPoint();                  // AutoPoint
static auto class_alias = AutoPointAlias{4, 5};         // AutoPointAlias
static auto class_qualified = AutoSpace::Inner{6};      // AutoSpace::Inner
static auto class_template = AutoBox<int>{7};           // AutoBox<int>
static auto class_forward = AutoForward{8};             // AutoForward
static auto long_brace = long{9};                       // long
static int point_x(AutoPoint p = AutoPoint{10, 11}) { return p.x; }
%}

// An enumerator of an enumeration in a namespace or a class deduces the qualified enumeration.
%inline %{
namespace AutoSpace { enum AutoShade { auto_light, auto_dark }; }
struct AutoHolder { enum AutoSize { auto_small, auto_big }; };
static auto namespace_enumerator = AutoSpace::auto_dark;        // AutoSpace::AutoShade
static auto class_enumerator = AutoHolder::auto_big;            // AutoHolder::AutoSize
%}

// An enumerator of an unscoped enumeration qualified by the enumeration's name, as C++11 allows.
%inline %{
enum AutoColour { auto_red, auto_green };
static auto qualified_enumerator = AutoColour::auto_green;                   // AutoColour
static auto nested_qualified_enumerator = AutoSpace::AutoShade::auto_dark;   // AutoSpace::AutoShade
static auto class_qualified_enumerator = AutoHolder::AutoSize::auto_big;     // AutoHolder::AutoSize
%}

%inline %{

// FIXME: Not currently handled by SWIG's parser:
//static auto constexpr greeting = "Hello";

// Direct-initialisation of an auto variable, deferred for now:
//static auto direct(42);

%}

%{
// Suppress -Wparentheses warnings since we're testing correct handling of
// operator precedence in the absence of parentheses to enforce the order.
#ifdef __GNUC__
# pragma GCC diagnostic ignored "-Wparentheses"
#endif
%}
%inline %{
// Regression test for #3058.
auto CAST_HAD_WRONG_PRECEDENCE1 = (0)*1+2;
auto CAST_HAD_WRONG_PRECEDENCE2 = (0)&1|2;
auto CAST_HAD_WRONG_PRECEDENCE3 = (0)-1|2;
auto CAST_HAD_WRONG_PRECEDENCE4 = (0)+1|2;
%}
