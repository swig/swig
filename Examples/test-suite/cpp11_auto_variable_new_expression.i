%module cpp11_auto_variable_new_expression

// An 'auto' variable initialised by a new-expression deduces a pointer to the type allocated.  Each variable is passed
// to a function taking exactly the type it should deduce, which fails if SWIG deduced any other type.

// Read only, as setting a pointer variable warns that it may leak memory.
%immutable;

%warnfilter(SWIGWARN_CPP11_AUTO) plus_after_initialiser;
%warnfilter(SWIGWARN_CPP11_AUTO) plus_after_array;
%warnfilter(SWIGWARN_CPP11_AUTO) parenthesised_type_id;
%warnfilter(SWIGWARN_CPP11_AUTO) lambda_auto;

// A macro spanning more than one line gets locator comments round its expansion, which must not stop the deduction.
%define NEW_WIDGET(A, B)
new Widget(A, B)
%enddef

%{
#include <new>
#include <utility>

#define NEW_WIDGET(A, B) new Widget(A, B)

// Storage for the placement new-expression, which SWIG does not need to see.
static double placement_storage[4];
%}

%inline %{
struct Widget {
  int value;
  Widget() : value(7) {}
  Widget(int a, int b) : value(a + b) {}
};

typedef Widget WidgetAlias;

namespace space {
  struct Scoped {
    int value;
    Scoped() : value(11) {}
  };
}

template<typename T> struct Box {
  T value;
  Box(T v) : value(v) {}
};

int global_count = 3;
int global_values[3] = {40, 41, 42};

int int_value(int *p) { return *p; }
int pointed_int_value(int **p) { return **p; }
int const_int_value(const int *p) { return *p; }
unsigned int unsigned_value(unsigned int *p) { return *p; }
unsigned int const_unsigned_value(const unsigned int *p) { return *p; }
unsigned long unsigned_long_value(unsigned long *p) { return *p; }
unsigned short unsigned_short_value(unsigned short *p) { return *p; }
int unsigned_char_value(unsigned char *p) { return *p; }
int signed_char_value(signed char *p) { return *p; }
double double_value(double *p) { return *p; }
int widget_value(Widget *w) { return w->value; }
int scoped_value(space::Scoped *s) { return s->value; }
int box_value(Box<int> *b) { return b->value; }
int pair_sum(std::pair<int, int> *p) { return p->first + p->second; }
int row_sum(int (*rows)[3], int row) { return rows[row][0] + rows[row][1] + rows[row][2]; }
int null_pointers(int **pointers, int count) { int n = 0; for (int i = 0; i < count; ++i) n += pointers[i] ? 0 : 1; return n; }
int null_widgets(Widget **widgets, int count) { int n = 0; for (int i = 0; i < count; ++i) n += widgets[i] ? 0 : 1; return n; }
int widget_at(Widget *widgets, int i) { return widgets[i].value; }
int int_at(int *values, int i) { return values[i]; }

// The forms of new-expression, each giving a pointer to what it allocates.
auto bare_int = new int;
auto parens_int = new int(5);
auto braced_int = new int{6};
auto nested_parens_int = new int((8));
auto const_int = new const int(9);
auto trailing_const_int = new int const(10);
auto double_number = new double(2.5);

// The fundamental types spelt with more than one word, in any order.
auto unsigned_int = new unsigned(12);
auto unsigned_int_empty = new unsigned int();
auto unsigned_int_array = new unsigned int[2]{24, 25};
auto const_unsigned_int = new const unsigned int(26);
auto unsigned_long_number = new unsigned long(27);
auto long_unsigned_int = new long unsigned int(28);
auto unsigned_short_number = new unsigned short(29);
auto unsigned_char_number = new unsigned char(30);
auto signed_char_number = new signed char(31);

auto plain_widget = new Widget;
auto args_widget = new Widget(1, 2);
auto braced_widget = new Widget{3, 4};
auto aliased_widget = new WidgetAlias(2, 3);
auto scoped_widget = new space::Scoped();
auto global_widget = new ::Widget(4, 4);
auto star_widget = new Widget(global_count > 2 ? 1 : 2, 3);

// A template-id, including one whose template arguments are separated by a comma.
auto boxed = new Box<int>(13);
auto paired = new std::pair<int, int>(3, 4);

// An array new-expression gives a pointer to the first element.
auto int_array = new int[3]{20, 21, 22};
auto sized_array = new int[global_count]();
auto widget_array = new Widget[2]{{1, 1}, {2, 3}};
auto rows = new int[2][3]{{1, 2, 3}, {4, 5, 6}};
auto int_pointers = new int *[2]();
auto widget_pointers = new Widget *[3]();

// A placement new-expression, and one naming the global allocation function.
auto placed_widget = new (placement_storage) Widget(5, 6);
auto nothrow_int = new (std::nothrow) int(14);
auto global_new_int = ::new int(23);

// The type allocated can itself be deduced.
auto auto_int = new auto(15);
auto auto_double = new auto(3.5);
auto const_auto_int = new const auto(16);
auto auto_braced = new auto{global_count};
auto auto_paren_address = new auto(&(global_count));
auto auto_unsigned = new auto(32u);
auto decltype_int = new decltype(global_count)(17);

// The placeholder is deduced from any expression an 'auto' variable is deduced from.
auto auto_sum = new auto(global_count + 1);
auto auto_scaled = new auto(global_count * 2.5);
auto auto_narrowed = new auto(static_cast<unsigned short>(global_count));
auto auto_widget = new auto(Widget(2, 5));
auto const_auto_difference = new const auto{global_count - 1};

// The placeholder is deduced from a subscript as well.
int *subscript_int = new auto(global_values[1]);
int *nested_subscript_int = new auto((global_values[0] + global_values[2]));
int *braced_subscript_int = new auto{global_values[2]};
auto subscript_auto = new auto(global_values[0]);

// An expression the grammar does not parse, such as a lambda, deduces no type but is kept as written.
int *lambda_int = new auto([](int x) { return x * 2; }(21));
int *nested_lambda_int = new auto(([](int x) { return x; }(40) + 3));
int *braced_lambda_int = new auto{[] { return 44; }()};
auto lambda_auto = new auto([](int x) { return x; });

// The placeholder can be decorated, and a declaration can declare more than one variable.
auto *decorated_widget = new Widget(9, 9);
const auto *decorated_const_int = new int(18);
auto first_int = new int(19), second_int = new int(20);
auto plain_number = 21, *number_pointer = new int(22);

namespace inner {
  auto nested_widget = new Widget(10, 10);
}

auto macro_widget = NEW_WIDGET(6, 6);

// The new-expression is part of a larger expression, or is a form SWIG does not parse, and no type is deduced.
auto plus_after_initialiser = new int(5) + 0;
auto plus_after_array = new int[3] + 1;
auto parenthesised_type_id = new (int *[3]);

// An ordinary variable after all of these is still seen.
int after_all = 99;
%}

// The value of a new-expression default argument is compiled into the wrapper with compactdefaultargs.
%feature("compactdefaultargs") auto_default;
%feature("compactdefaultargs") subscript_default;
%feature("compactdefaultargs") lambda_default;

%inline %{
// GCC 11 and earlier take the 'auto' of 'new auto' in a default argument for an auto parameter, so they are given 'new int'.
#if defined(SWIG) || !defined(__GNUC__) || defined(__clang__) || __GNUC__ >= 12
#define NEW_AUTO new auto
#else
#define NEW_AUTO new int
#endif
int auto_default(int *p = NEW_AUTO(global_count + 4)) { int v = *p; delete p; return v; }
int subscript_default(int *p = NEW_AUTO(global_values[1])) { int v = *p; delete p; return v; }
int lambda_default(int *p = NEW_AUTO([] { return 43; }()), int k = 1) { int v = *p * k; delete p; return v; }
%}

%template(BoxInt) Box<int>;
