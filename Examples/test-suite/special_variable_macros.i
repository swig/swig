%module special_variable_macros

// test $typemap() special variable function
// these tests are not typical of how $typemap() should be used, but it checks that it is mostly working

%warnfilter(SWIGWARN_GO_NAME_CONFLICT);                       /* Ignoring 'NewName' due to Go name ('NewName') conflict with 'Name' */

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4996) // 'strdup': The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: _strdup. See online help for details.
#endif
#include <stdlib.h>
#include <string.h>
%}

%ignore Name::operator=;

%inline %{
struct Name {
  Name(const char *n="none") : name(strdup(n ? n : "")) {}
  Name(const Name& x) : name(strdup(x.name)) {}
  Name& operator= (const Name& x)
  {
    if (this != &x) {
      free(this->name);
      this->name = strdup(x.name);
    }
    return *this;
  }
  ~Name () { free(this->name); }
  const char *getName() const { return name; };
  Name *getNamePtr() { return this; };
private:
  char *name;
};
struct NameWrap {
  NameWrap(const char *n="casternone") : name(n) {}
  Name *getNamePtr() { return &name; };
private:
  Name name;
};

// Global variable for testing whether examplekw was touched
int accessed_examplekw = 0;
%}

// check $1 and $input get expanded properly when used from $typemap()
%typemap(in, examplekw="accessed_examplekw=1;") Name *GENERIC ($*1_type temp)
%{
  /*%typemap(in) Name *GENERIC start */
  temp = Name("$specialname");
  (void)$input;
  $1 = ($1_ltype) &temp;
  /*%typemap(in) Name *GENERIC end */
%}

// This would never be done in real code, it is just a test of what madness can be done.
// Note that the special variable substitutions $*1_type, $descriptor etc are for NameWrap 
// even when used within the Name typemap via $typemap. I can't think of any useful use cases
// for this behaviour in the C/C++ typemaps, but it is possible.
%typemap(in) NameWrap *NAMEWRAP ($*1_type temp)
%{
  /*%typemap(in) NameWrap *NAMEWRAP start */
  temp = $*1_ltype("$descriptor");
  (void)$input;
  $1 = temp.getNamePtr();
  /*%typemap(in) NameWrap *NAMEWRAP end */
%}

// check $descriptor gets expanded properly when used in a fragment
%fragment("nameDescriptor", "header")
%{
/*%fragment("getNameDescriptor", "header") start */
static const char *nameDescriptor = "$descriptor(Name)";
/*%fragment("getNameDescriptor", "header") end */
%}


//////////////////////////////////////////////////////////////////////////////////////

// This should use Name *GENERIC typemap which ignores passed in Name * and instead uses a newly a newly constructed Name
// held in a typemap variable with name="$specialname"
%typemap(in) Name *jack {
// %typemap(in) Name *jack start
$typemap(in, Name *GENERIC)
$typemap(in:examplekw, Name *GENERIC)
// %typemap(in) Name *jack end
}

// as above, but also perform variable substitution
%typemap(in) Name *jill {
// %typemap(in) Name *jill start
$typemap(in, Name *GENERIC, specialname=jilly)
// %typemap(in) Name *jill end
}

%typemap(in) Name *mary {
// %typemap(in) Name *mary start
$typemap(in, NameWrap *NAMEWRAP)
// %typemap(in) Name *mary end
}

%typemap(in, fragment="nameDescriptor") Name *james (Name temp) {
  // %typemap(in) Name *james start
  temp = Name(nameDescriptor);
  (void)$input;
  $1 = &temp;
  // %typemap(in) Name *james end
}

%inline %{
const char * testFred(Name *fred) {
  return fred->getName();
}
const char * testJack(Name *jack) {
  return jack->getName();
}
const char * testJill(Name *jill) {
  return jill->getName();
}
const char * testMary(Name *mary) {
  return mary->getName();
}
const char * testJames(Name *james) {
  return james->getName();
}
%}

//////////////////////////////////////////////////////////////////////////////////////
// Multi-arg typemap lookup
// One would never do something like this in reality, it just checks $typemap with multi-arg typemaps
%typemap(in) (Name *multiname, int num)($*1_type temp_name, $2_ltype temp_count)
%{
  /*%typemap(in) (Name *multiname, int num) start */
  temp_name = $*1_ltype("multiname num");
  temp_count = (int)strlen(temp_name.getNamePtr()->getName());
  (void)$input;
  $1 = temp_name.getNamePtr();
  $2 = temp_count + 100;
  /*%typemap(in) (Name *multiname, int num) end */
%}

%typemap(in) (Name *jim, int count) {
// %typemap(in) Name *jim start
$typemap(in, (Name *multiname, int num))
// %typemap(in) Name *jim end
}

%inline %{
const char * testJim(Name *jim, int count) {
  if (count != (int)strlen(jim->getNamePtr()->getName()) + 100)
    return "size check failed";
  else
    return jim->getName();
}
%}

//////////////////////////////////////////////////////////////////////////////////////
// Template types with more than one template parameter

// check $1 and $input get expanded properly when used from $typemap()
%typemap(in) Space::Pair<int, bool> PAIR_INT_BOOL ($1_type temp)
%{
  /*%typemap(in) Name *GENERIC start */
  temp = Space::Pair<int, bool>(123, true);
  (void)$input;
  $1 = ($1_ltype)temp;
  /*%typemap(in) Name *GENERIC end */
%}

%typemap(in) Space::Pair<int, bool> john {
// %typemap(in) Name *john start
$typemap(in, Space::Pair<int, bool> PAIR_INT_BOOL)
// %typemap(in) Name *john end
}

%inline %{
namespace Space {
  template <typename T1, typename T2> struct Pair {
    Pair(T1 f, T2 s) : first(f), second(s) {}
    Pair() {}
    T1 first;
    T2 second;
  };
  int testJohn(Space::Pair<int, bool> john) {
    return john.first;
  }
}
%}
%template(PairIntBool) Space::Pair<int, bool>;

//////////////////////////////////////////////////////////////////////////////////////
// A real use case for $typemap()

#if defined(SWIGCSHARP)
%typemap(cscode) Space::RenameMe %{
  public static NewName factory(System.String s) {
  //below should expand to:
  //return new NewName( new Name(s) );
    return new $typemap(cstype, Space::RenameMe)( new $typemap(cstype, Name)(s) ); 
  }
%}
#elif defined(SWIGJAVA)
%typemap(javacode) Space::RenameMe %{
  public static NewName factory(String s) {
  //below should expand to:
  //return new NewName( new Name(s) );
    return new $typemap(jstype, Space::RenameMe)( new $typemap(jstype, Name)(s) ); 
  }
%}
#elif defined(SWIGD)
%typemap(dcode) Space::RenameMe %{
  public static NewName factory(string s) {
    return new $typemap(dtype, Space::RenameMe)( new $typemap(dtype, Name)(s) );
  }
%}
#endif

%rename(NewName) Space::RenameMe;
%inline %{
namespace Space {
  struct RenameMe {
    RenameMe(Name n) : storedName(n) {}
    Name getStoredName() { return storedName; }
  private:
    Name storedName;
  };
}
%}

//////////////////////////////////////////////////////////////////////////////////////
// Part 1: $typemap() and the 'out' typemap $1 variable override
// These typemaps for Pair use the std::string typemaps via $typemap() to morph the Pair return into returning just the (first) string value of the Pair.
// The 1=result_first variable override is needed in all the different target languages for returning a string instead of Pair.
// $typemap() does the target language specific std::string output handling

%include <std_string.i>
%typemap(out) Space::Pair<std::string, int> {
  /* start of out Pair<std::string, int> */
  const std::string& result_first = $1.first;
  $typemap(out, std::string, 1=result_first);
  /* end of out Pair<std::string, int> */
}
// Additional target language specific typemaps for the strongly typed languages to return a string instead of a Pair proxy
#if defined(SWIGCSHARP)
%typemap(ctype) Space::Pair<std::string, int> = std::string;
%typemap(imtype) Space::Pair<std::string, int> = std::string;
%typemap(cstype) Space::Pair<std::string, int> = std::string;
%typemap(csout) Space::Pair<std::string, int> = std::string;
#elif defined(SWIGD)
%typemap(ctype) Space::Pair<std::string, int> = std::string;
%typemap(imtype) Space::Pair<std::string, int> = std::string;
%typemap(dtype) Space::Pair<std::string, int> = std::string;
%typemap(dout) Space::Pair<std::string, int> = std::string;
#elif defined(SWIGGO)
%typemap(gotype) Space::Pair<std::string, int> = std::string;
%typemap(goout) Space::Pair<std::string, int> = std::string;
#elif defined(SWIGJAVA)
%typemap(jni) Space::Pair<std::string, int> = std::string;
%typemap(jtype) Space::Pair<std::string, int> = std::string;
%typemap(jstype) Space::Pair<std::string, int> = std::string;
%typemap(javaout) Space::Pair<std::string, int> = std::string;
#endif
%template() Space::Pair<std::string, int>;
%inline %{
Space::Pair<std::string, int> makeStringInt(const std::string& s, int i) {
  return Space::Pair<std::string, int>(s, i);
}
%}

// Part 2: $typemap() and the 'in' typemap $1 variable override
// Target language just passes in an int and the typemaps morph this into a Pair containing the stringified int and the input int
// $typemap() does the target language specific int as an input handling
%fragment("my_sstream", "header") %{#include <sstream>%}
%typemap(in, fragment="my_sstream") Space::Pair<std::string, int> {
  // start of in Pair<std::string, int>
  int& input_value_second = $1.second;
  $typemap(in, int, 1=input_value_second);

  // create string from int value plus one
  std::stringstream ss;
  ss << $1.second + 1;
  $1.first = ss.str();
  // end of in Pair<std::string, int>
}
#if defined(SWIGCSHARP)
%typemap(ctype) Space::Pair<std::string, int> = int;
%typemap(imtype) Space::Pair<std::string, int> = int;
%typemap(cstype) Space::Pair<std::string, int> = int;
%typemap(csin) Space::Pair<std::string, int> = int;
#elif defined(SWIGD)
%typemap(ctype) Space::Pair<std::string, int> = int;
%typemap(imtype) Space::Pair<std::string, int> = int;
%typemap(dtype) Space::Pair<std::string, int> = int;
%typemap(din) Space::Pair<std::string, int> = int;
#elif defined(SWIGGO)
%typemap(gotype) Space::Pair<std::string, int> = int;
#elif defined(SWIGJAVA)
%typemap(jni) Space::Pair<std::string, int> = int;
%typemap(jtype) Space::Pair<std::string, int> = int;
%typemap(jstype) Space::Pair<std::string, int> = int;
%typemap(javain) Space::Pair<std::string, int> = int;
#endif
%inline %{
std::string provideStringInt(Space::Pair<std::string, int> p) {
  return p.first;
}
%}
