%module li_std_string
%include <std_string.i>

#if defined(SWIGLUA) || defined(SWIGPHP) || defined(SWIGUTL)
%apply std::string& INPUT { std::string &input }
%apply std::string& INOUT { std::string &inout }
%apply std::string& OUTPUT { std::string &output }
#endif

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{

std::string test_value(std::string x) {
   return x;
}

const std::string& test_const_reference(const std::string &x) {
   return x;
}

void test_const_reference_returning_void(const std::string &) {
}

void test_const_reference_returning_void(const std::string &, int) {
}

void test_pointer(std::string *x) {
}

std::string *test_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_const_pointer(const std::string *x) {
}

const std::string *test_const_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_reference(std::string &x) {
}

std::string& test_reference_out() {
   static std::string x = "test_reference_out message";
   return x;
}

std::string test_reference_input(std::string &input) {
  // For PHP to allow checking that we haven't used the default string&
  // typemap which wraps as a PHP pass-by-reference string parameter.
  std::string copy = input;
  input = "MODIFIED";
  return copy;
}

void test_reference_inout(std::string &inout) {
  inout += inout;
}

void test_reference_output(std::string &output) {
  output = "output";
}

#ifdef SWIGPHP
// Test PHP-specific default wrapping string& as pass-by-ref PHP string.
void test_reference_php(std::string &s) {
  s += ".php";
}
#endif

void test_throw() TESTCASE_THROW1(std::string){
  static std::string x = "test_throw message";
  throw x;
}

void test_const_reference_throw() TESTCASE_THROW1(const std::string &){
  static std::string x = "test_const_reference_throw message";
  throw x;
}

void test_pointer_throw() TESTCASE_THROW1(std::string *) {
  throw new std::string("foo");
}

void test_const_pointer_throw() TESTCASE_THROW1(const std::string *) {
  throw new std::string("foo");
}
%}

/* Old way, now std::string is a %naturalvar by default
%apply const std::string& { std::string *GlobalString2, 
                            std::string *MemberString2, 
                            std::string *Structure::StaticMemberString2 };
*/

#ifdef SWIGSCILAB
%rename(St) MemberString;
%rename(Str) MemberString;
%rename(Str2) MemberString2;
%rename(StaticStr) StaticMemberString;
%rename(StaticStr2) StaticMemberString2;
%rename(ConstStr) ConstMemberString;
%rename(ConstStaticStr) ConstStaticMemberString;
#endif

%inline %{
std::string GlobalString;
std::string GlobalString2 = "global string 2";
const std::string ConstGlobalString = "const global string";

struct Structure {
  std::string MemberString;
  std::string MemberString2;
  static std::string StaticMemberString;
  static std::string StaticMemberString2;

  const std::string ConstMemberString;
  static const std::string ConstStaticMemberString;

  Structure() : MemberString2("member string 2"), ConstMemberString("const member string") {}
};
%}

%{
  std::string Structure::StaticMemberString = "static member string";
  std::string Structure::StaticMemberString2 = "static member string 2";
  const std::string Structure::ConstStaticMemberString = "const static member string";
%}


%inline %{
class Foo {
public:
   unsigned long long  test(unsigned long long l)
   {
       return l + 1;
   }
   std::string test(std::string l)
   {
       return l + "1";
   }

   unsigned long long  testl(unsigned long long l)
   {
       return l + 1;
   }

}; 
%}

%inline %{
  std::string stdstring_empty() {
    return std::string();
  }

  char *c_empty() {
    return (char *)"";
  }

  char *c_null() {
    return 0;
  }

  const char *get_null(const char *a) {
    return a == 0 ? a : "non-null";
  }
%}

#if defined(SWIGJAVA)
%javaconst(1);
#elif SWIGCSHARP
%csconst(1);
#elif SWIGD
%dmanifestconst;
#endif

%inline %{
const std::string aString = "something";
%}
%constant std::string MY_STRING = "";
%constant std::string MY_STRING_2 = "OK";
