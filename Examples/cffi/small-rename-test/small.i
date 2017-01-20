
%module small

%{
#include "small.h"
%}

%feature("export");

//%rename(newfuncnamefor_func) func;
//%rename(NewFuncNameFor_Func) Func;
//%rename(NEWFUNCNAMEFOR_FUNC) FUNC;

//%rename(newclassnamefor_testclass) testclass;
//%rename(NewClassNameFor_TestClass) TestClass;
//%rename(NEWCLASSNAMEFOR_TESTCLASS) TESTCLASS;

//%rename(new_method_namefor_cppmethod) cppmethod;
//%rename(New_Method_NameFor_CppMethod) CppMethod;
//%rename(NEW_METHOD_NAMEFOR_CPPMETHOD) CPPMETHOD;

%rename(newME) oldme;

%include "small.h"

