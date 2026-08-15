// Test the premature garbage collection prevention parameter (pgcpp) for the different ways of passing objects

%module java_pgcpp

#ifdef SWIGJAVA_SOURCE
%pragma(java) jniclassclassmodifiers="public class"

%typemap(javacode) Space::Classic %{
  public long getCPtrValue() {
    return this.swigCPtr;
  }
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) jniclassclassmodifiers="public object"

%typemap(javacode) Space::Classic %{
  fun getCPtrValue(): Long {
    return this.swigCPtr
  }
%}
#endif

// Default pointer to pointer typemaps do not use proxy class, so make sure that the pgcpp is generated for these typemaps
%typemap(jni) Space::Classic ** "jlong"
#ifdef SWIGJAVA_SOURCE
%typemap(jtype) Space::Classic ** "long"
#elif defined SWIGKOTLIN_SOURCE
%typemap(jtype) Space::Classic ** "Long"
#endif
%typemap(jstype) Space::Classic ** " Classic "
%typemap(javain) Space::Classic ** "Classic.getCPtr($javainput)"

// Default typemaps for pass by value, ref, pointer and pointer const reference should use pgcpp

%inline %{
namespace Space {
  struct Classic {
    Classic() {}
    Classic(Classic c1, Classic& c2, Classic* c3, Classic*const& c4, Classic** c5) {}
    Classic(const Classic c1, const Classic& c2, const Classic* c3, const Classic*const& c4, const Classic** c5, bool b) {}

    void method(Classic c1, Classic& c2, Classic* c3, Classic*const& c4, Classic** c5) {}
    void methodconst(const Classic c1, const Classic& c2, const Classic* c3, const Classic*const& c4, const Classic** c5) {}
  };

  void function(Classic c1, Classic& c2, Classic* c3, Classic*const& c4, Classic** c5) {}
  void functionconst(const Classic c1, const Classic& c2, const Classic* c3, const Classic*const& c4, const Classic** c5) {}
}
%}


#ifdef SWIGJAVA_SOURCE
%typemap(jtype)  Klassic *k1 "/*a*/ long   /*b*/ /*c*/"
%typemap(jstype) Klassic *k1 "/*a*/ Classic/*b*/ /*c*/"

%typemap(jtype)  Klassic *k2 "/*d*/ long"
%typemap(jstype) Klassic *k2 "/*d*/ Classic"

%typemap(jtype)  Klassic *k3 "long/*e*/ "
%typemap(jstype) Klassic *k3 "Classic/*e*/ "
#elif defined SWIGKOTLIN_SOURCE
%typemap(jtype)  Klassic *k1 "/*a*/ Long   /*b*/ /*c*/"
%typemap(jstype) Klassic *k1 "/*a*/ Classic/*b*/ /*c*/"

%typemap(jtype)  Klassic *k2 "/*d*/ Long"
%typemap(jstype) Klassic *k2 "/*d*/ Classic"

%typemap(jtype)  Klassic *k3 "Long/*e*/ "
%typemap(jstype) Klassic *k3 "Classic/*e*/ "
#endif

%typemap(javain) Klassic * "Classic.getCPtr($javainput)"

%{
typedef Space::Classic Klassic;
%}

%inline %{
  void comment_in_typemaps(Klassic *k1, Klassic *k2, Klassic *k3) {}
%}

