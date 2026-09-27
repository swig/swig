// This testcase checks SWIG's support for the 'decltype(auto)' placeholder introduced in C++14.
// It stands wherever the 'auto' placeholder does, but unlike 'auto' it deduces the declared type
// of the initialiser exactly, keeping any reference.
%module cpp14_decltype_auto

// A deduced return type cannot be deduced from the body, which SWIG does not analyse
%warnfilter(SWIGWARN_CPP14_AUTO) ret_plain;
%warnfilter(SWIGWARN_CPP14_AUTO) ret_trailing;
%warnfilter(SWIGWARN_CPP14_AUTO) Klass::mem;
%warnfilter(SWIGWARN_CPP14_AUTO) Klass::operator decltype(auto)();

%rename(convert) KlassMyDecltype::operator mydecltype;

%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda_dauto;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) global_ref;

// The u8, u and U encoding prefixes give a literal one of the char8_t, char16_t and char32_t
// character types, none of which SWIG has a type for, so these are ignored.
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_utf8;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_char16;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_char32;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_utf8;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_char16;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_char32;

// An operator applied to a string literal, or a cast of one, makes an expression of type 'const char *'.
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) var_string_expr;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) var_string_cast;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_paren_class;
%warnfilter(SWIGWARN_CPP11_AUTO) var_paren_function;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_paren_address;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_typedef_ref;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_new;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_new_klass;

%inline %{
int global_int = 42;
int &global_ref = global_int;

// Deduced from the initialiser, exactly as an 'auto' variable is.
decltype(auto) var_int = global_int;

// 'decltype(auto)' keeps the reference that 'auto' would drop.
decltype(auto) var_ref = global_ref;

const int global_const = 7;
decltype(auto) var_const = global_const;

// A string literal is an lvalue of array type, so these declare a reference to an array of
// characters and not the 'const char *' that ordinary 'auto' deduces.
decltype(auto) var_string = "text";
decltype(auto) var_string_wide = L"text";
decltype(auto) var_string_utf8 = u8"text";
decltype(auto) var_string_char16 = u"text";
decltype(auto) var_string_char32 = U"text";
decltype(auto) var_string_raw = R"(text)";
decltype(auto) var_string_raw_wide = LR"(text)";
decltype(auto) var_string_raw_utf8 = u8R"(text)";
decltype(auto) var_string_raw_char16 = uR"(text)";
decltype(auto) var_string_raw_char32 = UR"(text)";

// Adjacent literals concatenate into one literal, and parentheses do not change what a literal is.
decltype(auto) var_string_concat = "te" "xt";
decltype(auto) var_string_parens = ("text");

// An operator applied to a literal makes an expression, whose type is deduced as usual.
bool use_ext = true;
decltype(auto) var_string_expr = use_ext ? "ext" : "none";

// A cast of a literal is a prvalue of the type cast to, so this is a 'const char *' rather than a reference to an array.
decltype(auto) var_string_cast = (const char *)"text";

// A parenthesised name is an lvalue, so each of these deduces what 'decltype((name))' names, a reference to it.
struct Paren {
  int member;
  static int count;
};
int Paren::count = 3;
int paren_int = 1;
int *paren_ptr = &paren_int;
Paren paren_class = { 2 };
int paren_array[2] = { 4, 5 };
int paren_deref(int **pp) { return **pp; }

decltype(auto) var_paren_int = (paren_int);        // int &
decltype(auto) var_paren_nested = ((paren_int));   // int &
decltype(auto) var_paren_ptr = (paren_ptr);        // int *&
decltype(auto) var_paren_class = (paren_class);    // Paren &
decltype(auto) var_paren_array = (paren_array);    // int (&)[2]
decltype(auto) var_paren_static = (Paren::count);  // int &

// A name declared with a reference that a typedef hides keeps that one reference.
typedef int &ParenIntRef;
ParenIntRef paren_typedef_ref = paren_int;
decltype(auto) var_paren_typedef_ref = (paren_typedef_ref);  // int &

// A parenthesised enumerator deduces its enumeration, and a parenthesised function name deduces nothing, as for decltype.
namespace ParenSpace {
  enum ParenShade { paren_light, paren_dark };
}
int paren_function() { return 6; }
decltype(auto) var_paren_enumerator = (ParenSpace::paren_dark);  // ParenSpace::ParenShade
// MSVC rejects a parenthesised function name here (error C3556), and SWIG ignores the variable, so MSVC does not see it.
#if defined(SWIG) || !defined(_MSC_VER)
decltype(auto) var_paren_function = (paren_function);            // int (&)(), not deduced
#endif

// A parenthesised address is not a name, so this is the pointer and not a reference to one.
decltype(auto) var_paren_address = (&paren_int);  // int *
int paren_address_value(int *p) { return *p; }

// Return types, all ignored as the type would have to come from the body.
decltype(auto) ret_plain() { return global_int; }
auto ret_trailing() -> decltype(auto);

struct Klass {
  int v;

  explicit Klass(int v_) : v(v_) { }

  decltype(auto) mem() { return v; }

  // A conversion function cannot have a trailing return type, so this is ignored too.
  operator decltype(auto)() { return v; }

  int plain() const { return v; }
};

// A user defined type whose name merely ends in 'decltype' is not the keyword, so this is an ordinary
// conversion function and the %rename above names it.
struct mydecltype {
  int value;
};

struct KlassMyDecltype {
  operator mydecltype() const { mydecltype m; m.value = 13; return m; }
};

// A new-expression is a prvalue, so the pointer it gives is deduced as it is for 'auto'.
decltype(auto) var_new = new int(5);
decltype(auto) var_new_klass = new Klass(3);

int new_int_value(int *p) { return *p; }
int new_klass_value(Klass *k) { return k->v; }

// A lambda is wrapped as an opaque object whatever its return type is spelt as.
auto lambda_dauto = [](int x) -> decltype(auto) { return x; };
%}

#if !defined(SWIGOCAML)
// TODO: OCaml emits enum class enumerators unqualified
%inline %{
// A parenthesised enumerator of a scoped enumeration deduces its enumeration too.
namespace ParenSpace {
  enum class ParenScoped { scoped_light, scoped_dark };
}
decltype(auto) var_paren_scoped = (ParenSpace::ParenScoped::scoped_dark);  // ParenSpace::ParenScoped
%}
#endif
