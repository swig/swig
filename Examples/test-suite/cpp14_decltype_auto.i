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

// A string literal is an lvalue of array type, so this declares a reference to an array of
// characters and not the 'const char *' that ordinary 'auto' deduces.
%warnfilter(SWIGWARN_CPP11_AUTO) var_string;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_wide;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_utf8;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_char16;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_char32;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_wide;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_utf8;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_char16;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_raw_char32;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_concat;
%warnfilter(SWIGWARN_CPP11_AUTO) var_string_parens;

// An operator applied to a string literal makes an expression, and this one has type 'const char *'.
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) var_string_expr;

%warnfilter(SWIGWARN_CPP11_AUTO) var_parenthesised;

%inline %{
int global_int = 42;
int &global_ref = global_int;

// Deduced from the initialiser, exactly as an 'auto' variable is.
decltype(auto) var_int = global_int;

// 'decltype(auto)' keeps the reference that 'auto' would drop.
decltype(auto) var_ref = global_ref;

const int global_const = 7;
decltype(auto) var_const = global_const;

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

// A parenthesised name declares a reference to what it names, which the name was not declared with
decltype(auto) var_parenthesised = (global_int);

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

// A lambda is wrapped as an opaque object whatever its return type is spelt as.
auto lambda_dauto = [](int x) -> decltype(auto) { return x; };
%}
