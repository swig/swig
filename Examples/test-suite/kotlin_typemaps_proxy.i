/* Tests the Kotlin specific directives, mirroring java_typemaps_proxy */

%module kotlin_typemaps_proxy


%typemap(kimports) SWIGTYPE "import java.math.*"
%typemap(kcode) NS::Farewell %{
  fun saybye(num_times: java.math.BigDecimal) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(kclassmodifiers) NS::Farewell "public final class"

%typemap(kimports) NS::Greeting %{
import java.util.EventListener
%};

// In Kotlin the base class and interfaces share a single ':' clause, so kbase needs a
// constructor-call form. A Kotlin object that extends Exception has to invoke a super
// constructor, which the overridden kbody below provides.
%typemap(kbase) NS::Greeting "Exception"
%typemap(kinterfaces) NS::Greeting "EventListener"
%typemap(kcode) NS::Greeting %{
  // Pure Kotlin code generated using %typemap(kcode)
  fun sayhello() {
    hello()
  }
%}
// Static member generated using %typemap(kcompanion) - goes into the companion object
%typemap(kcompanion) NS::Greeting %{
    fun cheerio(e: EventListener) {
    }

    internal fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    internal fun swigRelease(obj: $kotlinclassname?): Long {
      var ptr = 0L
      if (obj != null) {
        if (!obj.swigCMemOwn)
          throw RuntimeException("Cannot release ownership as memory is not owned")
        ptr = obj.swigCPtr
        obj.swigCMemOwn = false
        obj.delete()
      }
      return ptr
    }
%}

// Create a new getCPtr() function which takes Kotlin null - the body holds the instance
// members and the pointer constructor (which must call super() as Greeting extends Exception)
%typemap(kbody) NS::Greeting %{
  internal var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}

// Make the pointer constructor public
%typemap(kbody) NS::Farewell %{
  internal var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  constructor(cPtr: Long, cMemoryOwn: Boolean) {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}
%typemap(kcompanion) NS::Farewell %{
    internal fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    internal fun swigRelease(obj: $kotlinclassname?): Long {
      var ptr = 0L
      if (obj != null) {
        if (!obj.swigCMemOwn)
          throw RuntimeException("Cannot release ownership as memory is not owned")
        ptr = obj.swigCPtr
        obj.swigCMemOwn = false
        obj.delete()
      }
      return ptr
    }
%}

// get rid of the finalize method for NS::Farewell (already empty by default in Kotlin)
%typemap(kfinalize) NS::Farewell ""

// Test typemaps are being found for templated classes
%typemap(kcompanion) NS::Adieu<int**> %{
    fun adieu() {
    }
%}

// Check the %kotlinmethodmodifiers feature
%kotlinmethodmodifiers NS::Farewell::methodmodifiertest() "private";

%inline %{
namespace NS {
    class Greeting {
    public:
        void hello() {}
        static void ciao(Greeting* g) {}
    };
    class Farewell {
    public:
        void methodmodifiertest() {}
    };
    template<class T> class Adieu {};
}
%}

%template(AdieuIntPtrPtr) NS::Adieu<int**>;

// Check the premature garbage collection prevention parameter can be turned off
%typemap(ktype, nopgcpp="1") Without * "Long"
%pragma(kotlin) jniclassclassmodifiers="public object"

%inline %{
struct Without {
  Without(Without *p) : var(0) {}
  static void static_method(Without *p) {}
  void member_method(Without *p) {}
  Without *var;
};
Without *global_without = 0;
void global_method_without(Without *p) {}
struct With {
  With(With *p) {}
  static void static_method(With *p) {}
  void member_method(With *p) {}
};
void global_method_with(With *p) {}
%}

%typemap(ktype, nopgcpp="1") const ConstWithout * "Long"
%inline %{
class ConstWithout {
public:
  ConstWithout(const ConstWithout *p) : const_var(0), var_const(0) {}
  static void static_method(const ConstWithout *p) {}
  void member_method(const ConstWithout *p) {}
  void const_member_method(const ConstWithout *p) const {}
  const ConstWithout * const_var;
  const ConstWithout * const var_const;
};
const ConstWithout * global_constwithout = 0;
void global_method_constwithout(const ConstWithout *p) {}
%}


// $imfuncname substitution
%typemap(kout) int imfuncname_test {
    return $imclassname.$imfuncname(swigCPtr, this) + 123
  }
%typemap(kout) int imfuncname_static_test {
    return $imclassname.$imfuncname() + 234
  }
%typemap(kout) int imfuncname_global_test {
    return $imclassname.$imfuncname() + 345
  }
%inline %{
struct ProxyA {
  int imfuncname_test() { return 0; }
  static int imfuncname_static_test() { return 0; }
};
int imfuncname_global_test() { return 0; }
%}
