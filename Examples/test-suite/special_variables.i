%module(directors="1") special_variables

%include <std_string.i>

// will fail to compile if $symname is not expanded
%typemap(argout) int i {
  $symname(99);
}

%{
#define KKK_testmethod testmethod
#define KKK_teststaticmethod KKK::teststaticmethod
%}

%inline %{
void testmethod(int i) {}
struct KKK {
  void testmethod(int i) {}
  static void teststaticmethod(int i) {}
};
%}

%{
std::string ExceptionVars(double i, double j) {
  return "a1";
}
%}

%rename(ExceptionVars) Space::exceptionvars;

#ifdef SWIGC

%exception Space::exceptionvars %{
  $action
  result = (char*)$symname(1.0,2.0).c_str(); // Should expand to ExceptionVars
  result = (char*)$name(3.0,4.0).c_str(); // Should expand to Space::exceptionvars
  // above will not compile if the variables are not expanded properly
  result = (char*)"$action  $name  $symname  $overname $wrapname";
%}

#else

%exception Space::exceptionvars %{
  $action
  result = $symname(1.0,2.0); // Should expand to ExceptionVars
  result = $name(3.0,4.0); // Should expand to Space::exceptionvars
  // above will not compile if the variables are not expanded properly
  result = "$action  $name  $symname  $overname $wrapname $parentclassname $parentclasssymname";
%}

#endif

%inline %{
namespace Space {
std::string exceptionvars(double i, double j) {
  return "b2";
}
}
%}


#ifdef SWIGC

%exception Space::overloadedmethod %{
  $action
  result = (char*)Space::$symname(1.0).c_str();
  result = (char*)$name().c_str();
  result = (char*)$name(2.0).c_str();
  // above will not compile if the variables are not expanded properly
  result = (char*)"$action  $name  $symname  $overname $wrapname";
  // $decl
%}

#else

%exception Space::overloadedmethod %{
  $action
  result = Space::$symname(1.0);
  result = $name();
  result = $name(2.0);
  // above will not compile if the variables are not expanded properly
  result = "$action  $name  $symname  $overname $wrapname $parentclassname $parentclasssymname";
  // $decl
%}

#endif

%inline %{
namespace Space {
  std::string overloadedmethod(double j) {
    return "c3";
  }
  std::string overloadedmethod() {
    return "d4";
  }
}
std::string declaration;
%}

%exception {
  $action
  declaration = "$fulldecl $decl";
}

%rename(toInt) SpaceNamespace::ABC::operator int;

%allowexception SpaceNamespace::ABC::funcptrvar;
%allowexception SpaceNamespace::ABC::stringvar;
%allowexception SpaceNamespace::globalfuncptrvar;
%allowexception SpaceNamespace::UnnamedEnumHolder::unnamedenumvar;
%allowexception SpaceNamespace::UnnamedEnumItem;

%inline %{
namespace SpaceNamespace {
  struct ABC {
    ABC(int a, double b) : funcptrvar(0) {}
    ABC() : funcptrvar(0) {}
    // Before staticmethod, as the Python decorator of a static method after it would name the method instead of the builtin
    static int (*funcptrmethod(int x))(int, int) { return 0; }
    static short * staticmethod(int x, bool b) { return 0; }
    short * instancemethod(int x, bool b = false) { return 0; }
    short * constmethod(int x) const { return 0; }
    operator int() const { return 0; }
    int (*funcptrvar)(int);
    std::string stringvar;
  };
  template<typename T> struct Template {
    std::string tmethod(T t) { return ""; }
  };
  void globtemplate(Template<ABC> t) {}
  int (*globalfuncptrvar)(int) = 0;
  struct UnnamedEnumHolder {
    UnnamedEnumHolder() : unnamedenumvar(UnnamedMemberEnumItem) {}
    enum { UnnamedMemberEnumItem } unnamedenumvar;
  };
  enum { UnnamedEnumItem };
}
%}

%template(TemplateABC) SpaceNamespace::Template<SpaceNamespace::ABC>;

// noexcept is C++11 and throw is invalid in C++17 and later, only SWIG to use them
#define TESTCASE_NOEXCEPT noexcept
#define TESTCASE_NOEXCEPT_FALSE noexcept(false)
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_NOEXCEPT
#define TESTCASE_NOEXCEPT_FALSE
#define TESTCASE_THROW1(T1)
%}

%inline %{
namespace SpaceNamespace {
  struct ExceptionSpec {
    ExceptionSpec() TESTCASE_NOEXCEPT_FALSE {}
    ~ExceptionSpec() TESTCASE_NOEXCEPT {}
    short * constnoexceptmethod(int x) const TESTCASE_NOEXCEPT { return 0; }
    static int (*noexceptfuncptrmethod(int x) TESTCASE_NOEXCEPT)(int, int) { return 0; }
    void throwmethod(int x) TESTCASE_THROW1(int) {}
  };
}
%}

%inline %{
namespace SpaceNamespace {
  typedef short * TypedefFunction(int);
  typedef short * ConstTypedefFunction(int) const;
  TypedefFunction typedeffunction;
  struct TypedefMethods {
    ConstTypedefFunction typedefmethod;
  };
}
%}

%{
short *SpaceNamespace::typedeffunction(int) { return 0; }
short *SpaceNamespace::TypedefMethods::typedefmethod(int) const { return 0; }
%}

/////////////////////////////////// directors /////////////////////////////////
%{
void DirectorTest_director_testmethod(int i) {}
void DirectorTest_director_testmethodSwigExplicitDirectorTest(int i) {}
%}
%typemap(directorargout) int i {
  $symname(99);
  int isvoid_special_variable = $isvoid;
  (void)isvoid_special_variable;
}
%feature("director") DirectorTest;
%inline %{
void director_testmethod(int i) {}
struct DirectorTest {
  virtual void director_testmethod(int i) {}
  virtual ~DirectorTest() {}
};
%}


/////////////////////////////////// parentclasssymname parentclassname /////////////////////////////////
%exception instance_def {
  $action
  $parentclasssymname_aaa();
  $parentclassname_bbb();
  // above will not compile if the variables are not expanded properly
}
%exception static_def {
  $action
  $parentclasssymname_aaa();
  $parentclassname_bbb();
  // above will not compile if the variables are not expanded properly
}

%{
void DEFNewName_aaa() {}
namespace SpaceNamespace {
  void DEF_bbb() {}
}
%}

%rename(DEFNewName) DEF;
%inline %{
namespace SpaceNamespace {
  struct DEF : ABC {
    void instance_def() {}
    static void static_def() {}
  };
}
%}

