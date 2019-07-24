%module destructor_methodmodifiers

// This test changes the proxy classes so that they cannot be inherited from in the target language
// Previously the %csmethodmodifiers, %dmethodmodifiers, %javamethodmodifiers on destructors were ignored
// Now they can control the dispose/Dispose/delete method modifiers

#if defined(SWIGCSHARP)

// remove all use of protected and virtual keywords
%typemap(csclassmodifiers) NotForDeriving1, NotForDeriving2 "public sealed class"
%csmethodmodifiers NotForDeriving1::~NotForDeriving1 "public /*not virtual nor override*/";
%csmethodmodifiers NotForDeriving2::~NotForDeriving2 "public /*not virtual nor override*/";

// remove protected keyword to remove compiler warning
%typemap(csbody) NotForDeriving1, NotForDeriving2 %{
  private global::System.Runtime.InteropServices.HandleRef swigCPtr;
  private /*protected*/ bool swigCMemOwn;

  internal $csclassname(global::System.IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = new global::System.Runtime.InteropServices.HandleRef(this, cPtr);
  }

  internal static global::System.Runtime.InteropServices.HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero) : obj.swigCPtr;
  }
%}

#elif defined(SWIGD)

%typemap(dclassmodifiers) NotForDeriving1, NotForDeriving2 "final class"
%dmethodmodifiers NotForDeriving1::~NotForDeriving1 "public final";
%dmethodmodifiers NotForDeriving2::~NotForDeriving2 "public final";

#elif defined(SWIGJAVA)

%typemap(javaclassmodifiers) NotForDeriving1, NotForDeriving2 "public final class"
%javamethodmodifiers NotForDeriving1::~NotForDeriving1 "public synchronized final";
%javamethodmodifiers NotForDeriving2::~NotForDeriving2 "public synchronized final";

#endif

%inline %{
//#include <iostream>
struct NotForDeriving1 {
  void notvirtual() {}
  ~NotForDeriving1() {
//    std::cout << "~NotForDeriving1 called" << std::endl;
  }
};
struct NotForDeriving2 {
  void notvirtual() {}
#if defined(SWIG)
%extend {
  ~NotForDeriving2() {
//    std::cout << "~NotForDeriving2 called" << std::endl;
  }
}
#endif
};
%}
