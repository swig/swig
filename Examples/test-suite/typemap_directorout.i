// Test named output typemaps used in directors are found during the typematch search
%module(directors="1") typemap_directorout

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) Class1;

%feature("director");

%typemap(out) MyType & %{ WILL_NOT_COMPILE %}
%typemap(out) MyType &USEME = SWIGTYPE &;
%typemap(out) MyType &Class1::foo2, MyType &foo1 %{ /* special start */ $typemap(out, MyType &USEME) /* special end */ %}

%typemap(directorout) MyType & %{ WILL_NOT_COMPILE %}
// Can't use the %typemap(directorout) MyType & = SWIGTYPE & approach as non-director languages don't define any directorout typemaps
%typemap(directorout) MyType &Class1::foo2, MyType &foo1 %{ /* special start */ $input = 0; /* special end */ %}

#ifdef SWIGPHP
%typemap(directorout, warning="PHP directorout typemaps need fixing") MyType &Class1::foo2, MyType &foo1 %{ /* special start */ /*$input = 0;*/ /* special end */ %}
/* Patch to make $input work same as other languages. Then $input needs changing to &$input in most (maybe all) typemaps.
--- a/Source/Modules/php.cxx
+++ b/Source/Modules/php.cxx
@@ -2631,8 +2631,7 @@ done:
       if (!is_void) {
        tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), w);
        if (tm != 0) {
-         static const String *amp_result = NewStringf("&%s", Swig_cresult_name());
-         Replaceall(tm, "$input", amp_result);
+         Replaceall(tm, "$input", Swig_cresult_name());
          char temp[24];
          sprintf(temp, "%d", idx);
          Replaceall(tm, "$argnum", temp);
*/
#endif


#ifdef SWIGCSHARP
%typemap(csdirectorout) MyType & %{ WILL_NOT_COMPILE %}
%typemap(csdirectorout) MyType &USEME = SWIGTYPE &;
%typemap(csdirectorout) MyType &Class1::foo2, MyType &foo1 %{ /* special start */ $typemap(csdirectorout, MyType &USEME) /* special end */ %}
#endif

#ifdef SWIGD
%typemap(ddirectorout) MyType & %{ WILL_NOT_COMPILE %}
%typemap(ddirectorout) MyType &USEME = SWIGTYPE &;
%typemap(ddirectorout) MyType &Class1::foo2, MyType &foo1 %{ /* special start */ $typemap(ddirectorout, MyType &USEME) /* special end */ %}
#endif

#ifdef SWIGJAVA
%typemap(javadirectorout) MyType & %{ WILL_NOT_COMPILE %}
%typemap(javadirectorout) MyType &USEME = SWIGTYPE &;
%typemap(javadirectorout) MyType &Class1::foo2, MyType &foo1 %{ /* special start */ $typemap(javadirectorout, MyType &USEME) /* special end */ %}
#endif

%inline %{
typedef int MyType;
class Class1
{
  MyType mt;
public:
  Class1() : mt() {}
  virtual MyType & foo1() { return mt; }
  virtual MyType & foo2(int parm1) { return mt; }
  virtual MyType & foo2() { return mt; }
  virtual ~Class1() {}
};
%}

