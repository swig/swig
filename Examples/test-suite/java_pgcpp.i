// Test the premature garbage collection prevention parameter (pgcpp) for the different ways of passing objects

%module java_pgcpp

%pragma(java) jniclassclassmodifiers="public class"

%typemap(javacode) Space::Classic %{
  public long getCPtrValue() {
    return this.swigCPtr;
  }
%}

// Default pointer to pointer typemaps do not use proxy class, so make sure that the pgcpp is generated for these typemaps
%typemap(jni) Space::Classic ** "jlong"
%typemap(jtype) Space::Classic ** "long"
%typemap(jstype) Space::Classic ** " Classic "
%typemap(javain) Space::Classic ** "Classic.getCPtr($javainput)"

// Default typemaps for pass by value, ref, pointer and pointer reference should use pgcpp

%inline %{
namespace Space {
  struct Classic {
    Classic() {}
    Classic(Classic c1, Classic& c2, Classic* c3, Classic*& c4, Classic** c5) {}
    Classic(const Classic c1, const Classic& c2, const Classic* c3, const Classic*& c4, const Classic** c5, bool b) {}

    void method(Classic c1, Classic& c2, Classic* c3, Classic*& c4, Classic** c5) {}
    void methodconst(const Classic c1, const Classic& c2, const Classic* c3, const Classic*& c4, const Classic** c5) {}
  };

  void function(Classic c1, Classic& c2, Classic* c3, Classic*& c4, Classic** c5) {}
  void functionconst(const Classic c1, const Classic& c2, const Classic* c3, const Classic*& c4, const Classic** c5) {}
}
%}

