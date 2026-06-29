%module kotlin_nspacewithoutpackage

// This testcase checks the SWIGWARN_KOTLIN_NSPACE_WITHOUT_PACKAGE (796) warning that is emitted
// when the %nspace feature is used but no -package option is supplied to SWIG. The warning is
// suppressed below with %warnfilter so the generated code still compiles cleanly under -Werror.
//
// HARNESS NOTE: To actually emit warning 796, SWIG must be run WITHOUT -package. The kotlin
// Makefile.in always passes "-package $*" (via KOTLIN_PACKAGEOPT) and has no per-test override
// for this test (the java Makefile.in sets "java_nspacewithoutpackage.%: JAVA_PACKAGEOPT ="). To
// replicate that wiring without editing the Makefile, run:
//   make kotlin_nspacewithoutpackage.cpptest KOTLIN_PACKAGEOPT=
// which drops -package and exercises the warning path. With the default package the warning is
// not triggered (nspace + package is the normal supported case) but the testcase still
// generates and compiles, validating the nspace code generation either way.

%warnfilter(SWIGWARN_JAVA_NSPACE_WITHOUT_PACKAGE, SWIGWARN_KOTLIN_NSPACE_WITHOUT_PACKAGE) TopLevel::Foo;
%warnfilter(SWIGWARN_JAVA_NSPACE_WITHOUT_PACKAGE, SWIGWARN_KOTLIN_NSPACE_WITHOUT_PACKAGE) TopLevel::Bar;

%pragma(kotlin) jniclasspackage="PragmaDefinedPackage"

SWIG_KOTLINBODY_PROXY(public, public, SWIGTYPE)
SWIG_KOTLINBODY_TYPEWRAPPER(public, public, public, SWIGTYPE)

%include <std_string.i>

%nspace TopLevel::Foo;
%nspace TopLevel::Bar;

%{
	#include <string>
%}

%inline %{

namespace TopLevel
{
  class Foo {
  public:
    virtual ~Foo() {}
    virtual std::string ping() { return "TopLevel::Foo::ping()"; }
  };

  class Bar {
  public:
    virtual ~Bar() {}
    virtual std::string pong() { return "TopLevel::Bar::pong()"; }
  };
}

%}
