/* Contrived example to test the Java specific directives on the type wrapper classes */

%module java_typemaps_typewrapper


%typemap(javaimports) SWIGTYPE * "import java.math.*;"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javacode) Farewell * %{
  public static $javaclassname CreateNullPointer() {
    return new $javaclassname();
  }
  public void saybye(BigDecimal num_times) {
    // BigDecimal requires the java.math library
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javacode) Farewell * %{
  fun saybye(num_times: java.math.BigDecimal) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(javacompanion) Farewell * %{
    fun CreateNullPointer(): $javaclassname {
      return $javaclassname()
    }
    internal fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}
#endif /* SWIGJAVA_TARGET */
%typemap(javaclassmodifiers) Farewell * "public final class"

%typemap(javaimports) Greeting * %{
import java.util.*; // for EventListener
import java.lang.*; // for Exception
%};

%typemap(javabase) Greeting * "Exception"
%typemap(javainterfaces) Greeting * "EventListener"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javacode) Greeting * %{
  public static final long serialVersionUID = 0x52151000; // Suppress ecj warning
  // Pure Java code generated using %typemap(javacode) 
  public static $javaclassname CreateNullPointer() {
    return new $javaclassname();
  }

  public void sayhello() {
    $javaclassname.cheerio(new $javaclassname());
  }

  public static void cheerio(EventListener e) {
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javacode) Greeting * %{
  // Pure Java code generated using %typemap(javacode) 
  fun sayhello() {
    cheerio($javaclassname())
  }
%}
%typemap(javacompanion) Greeting * %{
    fun CreateNullPointer(): $javaclassname {
      return $javaclassname()
    }

    fun cheerio(e: EventListener) {
    }
    internal fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}

// Create a new getCPtr() function which takes Kotlin null and is public
// Make the pointer constructor public. The pointer and default constructors must call
// super() because Greeting * extends Exception.
%typemap(javabody) Greeting * %{
  internal var swigCPtr: Long

  constructor(cPtr: Long, @Suppress("UNUSED_PARAMETER") bFutureUse: Boolean) : super() {
    swigCPtr = cPtr;
  }

  constructor() : super() {
    swigCPtr = 0L;
  }
%}
#endif /* SWIGJAVA_TARGET */

// Create a new getCPtr() function which takes Java null and is public
// Make the pointer constructor public
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) Farewell * %{
  private transient long swigCPtr;

  public $javaclassname(long cPtr, boolean bFutureUse) {
    swigCPtr = cPtr;
  }

  protected $javaclassname() {
    swigCPtr = 0;
  }

  public static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0L : obj.swigCPtr;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody) Farewell * %{
  internal var swigCPtr: Long

  constructor(cPtr: Long, @Suppress("UNUSED_PARAMETER") bFutureUse: Boolean) {
    swigCPtr = cPtr;
  }

  constructor() {
    swigCPtr = 0L;
  }
%}
#endif /* SWIGJAVA_TARGET */

%{
class Greeting {};
class Farewell {};
%}

%inline %{
    Greeting* solong(Farewell* f) { return NULL; }
%}

// Illegal special variable crash
%typemap(jstype) WasCrashing "$javaclassname /*jstype $*javaclassname*/" // $*javaclassname was causing crash
%inline %{
struct WasCrashing {};
void hoop(WasCrashing was) {}
%}

