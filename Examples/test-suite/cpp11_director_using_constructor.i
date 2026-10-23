%module(directors="1") cpp11_director_using_constructor

// This testcase uses cpp11_using_constructor.i for testing that the expected
// constructors are available in director mode.

%feature("director");

%warnfilter(SWIGWARN_LANG_DIRECTOR_ABSTRACT) TemplateConstructor1Derived;
%warnfilter(SWIGWARN_LANG_DIRECTOR_ABSTRACT) TemplateConstructor2Base;
%warnfilter(SWIGWARN_LANG_DIRECTOR_ABSTRACT) TemplateConstructor2Derived;

// Lua-specific: suppress overload shadowing warnings for template constructors
// These warnings occur because Lua's overload resolution handles int/double/char* 
// differently than Python/Java
#ifdef SWIGLUA
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) TemplateConstructor2Base::TemplateConstructor2Base;
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) TemplateConstructor2Derived::TemplateConstructor2Derived;
#endif

%include "cpp11_using_constructor.i"
