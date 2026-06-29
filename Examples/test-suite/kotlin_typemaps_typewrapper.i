/* Contrived example to test the Kotlin specific directives on the type wrapper classes */

%module kotlin_typemaps_typewrapper


%typemap(kimports) SWIGTYPE * "import java.math.*"
%typemap(kcode) Farewell * %{
  fun saybye(num_times: java.math.BigDecimal) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(kcompanion) Farewell * %{
    fun CreateNullPointer(): $kotlinclassname {
      return $kotlinclassname()
    }
    internal fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}
%typemap(kclassmodifiers) Farewell * "public final class"

%typemap(kimports) Greeting * %{
import java.util.EventListener
%};

// In Kotlin the base class and interfaces share a single ':' clause. A class extending
// Exception must call a super constructor, which the overridden kbody below provides.
%typemap(kbase) Greeting * "Exception"
%typemap(kinterfaces) Greeting * "EventListener"
%typemap(kcode) Greeting * %{
  // Pure Kotlin code generated using %typemap(kcode)
  fun sayhello() {
    cheerio($kotlinclassname())
  }
%}
%typemap(kcompanion) Greeting * %{
    fun CreateNullPointer(): $kotlinclassname {
      return $kotlinclassname()
    }

    fun cheerio(e: EventListener) {
    }
    internal fun getCPtr(obj: $kotlinclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}

// Create a new getCPtr() function which takes Kotlin null and is public
// Make the pointer constructor public. The pointer and default constructors must call
// super() because Greeting * extends Exception.
%typemap(kbody) Greeting * %{
  internal var swigCPtr: Long

  constructor(cPtr: Long, @Suppress("UNUSED_PARAMETER") bFutureUse: Boolean) : super() {
    swigCPtr = cPtr
  }

  constructor() : super() {
    swigCPtr = 0L
  }
%}

%typemap(kbody) Farewell * %{
  internal var swigCPtr: Long

  constructor(cPtr: Long, @Suppress("UNUSED_PARAMETER") bFutureUse: Boolean) {
    swigCPtr = cPtr
  }

  constructor() {
    swigCPtr = 0L
  }
%}

%{
class Greeting {};
class Farewell {};
%}

%inline %{
    Greeting* solong(Farewell* f) { return NULL; }
%}

// Illegal special variable crash
%typemap(kstype) WasCrashing "$kotlinclassname /*kstype $*kotlinclassname*/" // $*kotlinclassname was causing crash
%inline %{
struct WasCrashing {};
void hoop(WasCrashing was) {}
%}
