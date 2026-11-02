/*
 * Test reserved keyword renaming
 */

%module keyword_rename

%feature("kwargs");

#pragma SWIG nowarn=SWIGWARN_PARSE_KEYWORD

/* A %rename to a keyword, which the keyword's %namewarn then renames again */
%rename(def) keyword_def;
%rename(native) keyword_native;
%rename(lock) keyword_lock;

/* A %rename to a C++ keyword, which the C target language's %namewarn then renames again */
%rename("new") keyword_new;
%rename("explicit") KeywordClass;
%rename("typename") KeywordEnum;
%rename("noexcept") KeywordEnumValue;

%inline %{

#define KW(x, y) int x (int y) { return y; }

/* Python keywords */
KW(in, except)
KW(except, in)
KW(pass, in)

/* Perl keywords */
KW(tie, die)
KW(use, next)

/* Java keywords */
KW(implements, native)
KW(synchronized, final)

/* C# Keywords */
KW(string, out)
struct stackalloc {int i;};

/* Go Keywords */
KW(go, defer)
KW(chan, fallthrough)

/* Lua keywords */
KW(end, function)
KW(nil,local)

/* Javascript keywords */
KW(instanceof, finally)
KW(finally, instanceof)
KW(yield, with)

/* Renamed to a Python and Ruby, a Java and a C# keyword */
KW(keyword_def, x)
KW(keyword_native, x)
KW(keyword_lock, x)

/* Renamed to C++ keywords */
KW(keyword_new, x)

struct KeywordClass {
  int i;
};

enum KeywordEnum { KeywordEnumValue };

enum KeywordEnum keyword_enum(enum KeywordEnum e) { return e; }

/* Keywords used as member variables shouldn't be renamed in Javascript. */
struct S {
  int yield;
};

struct S make_S_with_yield(int yield) {
  struct S s;
  s.yield = yield;
  return s;
}

%}


