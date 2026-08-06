/* Tests the Java specific directives */

%module java_typemaps_proxy


%typemap(javaimports) SWIGTYPE "import java.math.*;"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javacode) NS::Farewell %{
  public void saybye(BigDecimal num_times) {
    // BigDecimal requires the java.math library
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javacode) NS::Farewell %{
  @Suppress("UNUSED_PARAMETER")
  fun saybye(num_times: java.math.BigDecimal) {
    // BigDecimal requires the java.math library
  }
%}
#endif /* SWIGJAVA_TARGET */
%typemap(javaclassmodifiers) NS::Farewell "public final class"

%typemap(javaimports) NS::Greeting %{
import java.util.*; // for EventListener
import java.lang.*; // for Exception
%};

%typemap(javabase) NS::Greeting "Exception"
%typemap(javainterfaces) NS::Greeting "EventListener"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javacode) NS::Greeting %{
  public static final long serialVersionUID = 0x52151000; // Suppress ecj warning
  // Pure Java code generated using %typemap(javacode) 
  public void sayhello() {
    hello();
  }

  public static void cheerio(EventListener e) {
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javacode) NS::Greeting %{
  // Pure Java code generated using %typemap(javacode) 
  fun sayhello() {
    hello()
  }
%}
// Static member generated using %typemap(javacompanion) - goes into the companion object
%typemap(javacompanion) NS::Greeting %{
    @Suppress("UNUSED_PARAMETER")
    fun cheerio(e: EventListener) {
    }

    internal fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    internal fun swigRelease(obj: $javaclassname?): Long {
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
#endif /* SWIGJAVA_TARGET */

// Create a new getCPtr() function which takes Java null and is public
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) NS::Greeting %{
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  public static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody) NS::Greeting %{
  internal var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}
#endif /* SWIGJAVA_TARGET */

// Make the pointer constructor public
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) NS::Farewell %{
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  public $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody) NS::Farewell %{
  internal var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  constructor(cPtr: Long, cMemoryOwn: Boolean) {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}
%typemap(javacompanion) NS::Farewell %{
    internal fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }

    internal fun swigRelease(obj: $javaclassname?): Long {
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
#endif /* SWIGJAVA_TARGET */

// get rid of the finalize method for NS::Farewell
%typemap(javafinalize) NS::Farewell ""

// Test typemaps are being found for templated classes
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javacode) NS::Adieu<int**> %{
  public static void adieu() {
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javacompanion) NS::Adieu<int**> %{
    fun adieu() {
    }
%}
#endif /* SWIGJAVA_TARGET */

// Check the %javamethodmodifiers feature
%javamethodmodifiers NS::Farewell::methodmodifiertest() "private";

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
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype, nopgcpp="1") Without * "long"
%pragma(java) jniclassclassmodifiers="public class"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(jtype, nopgcpp="1") Without * "Long"
%pragma(java) jniclassclassmodifiers="public object"
#endif /* SWIGJAVA_TARGET */

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

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype, nopgcpp="1") const ConstWithout * "long"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(jtype, nopgcpp="1") const ConstWithout * "Long"
#endif /* SWIGJAVA_TARGET */
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
%typemap(javaout) int imfuncname_test {
    return $moduleJNI.$imfuncname(swigCPtr, this) + 123;
  }
%typemap(javaout) int imfuncname_static_test {
    return $moduleJNI.$imfuncname() + 234;
  }
%typemap(javaout) int imfuncname_global_test {
    return $moduleJNI.$imfuncname() + 345;
  }
%inline %{
struct ProxyA {
  int imfuncname_test() { return 0; }
  static int imfuncname_static_test() { return 0; }
};
int imfuncname_global_test() { return 0; }
%}
