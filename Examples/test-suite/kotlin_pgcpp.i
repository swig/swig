// Test the premature garbage collection prevention parameter (pgcpp) for the different ways of passing objects

%module kotlin_pgcpp

%pragma(kotlin) jniclassclassmodifiers="public object"

%typemap(kcode) Space::Classic %{
  fun getCPtrValue(): Long {
    return this.swigCPtr
  }
%}

// Default pointer to pointer typemaps do not use proxy class, so make sure that the pgcpp is generated for these typemaps
%typemap(jni) Space::Classic ** "jlong"
%typemap(ktype) Space::Classic ** "Long"
%typemap(kstype) Space::Classic ** " Classic "
%typemap(kin) Space::Classic ** "Classic.getCPtr($kotlininput)"

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


%typemap(ktype)  Klassic *k1 "/*a*/ Long   /*b*/ /*c*/"
%typemap(kstype) Klassic *k1 "/*a*/ Classic/*b*/ /*c*/"

%typemap(ktype)  Klassic *k2 "/*d*/ Long"
%typemap(kstype) Klassic *k2 "/*d*/ Classic"

%typemap(ktype)  Klassic *k3 "Long/*e*/ "
%typemap(kstype) Klassic *k3 "Classic/*e*/ "

%typemap(kin) Klassic * "Classic.getCPtr($kotlininput)"

%{
typedef Space::Classic Klassic;
%}

%inline %{
  void comment_in_typemaps(Klassic *k1, Klassic *k2, Klassic *k3) {}
%}
