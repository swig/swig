/* Contrived example to test the Java specific directives on the type wrapper classes */

%module java_typemaps_typewrapper


%typemap(javaimports) SWIGTYPE * "import java.math.*;";
%typemap(javacode) Farewell * %{
  public static $javaclassname CreateNullPointer() {
    return new $javaclassname();
  }
  public void saybye(BigDecimal num_times) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(javaclassmodifiers) Farewell * "public final";

%typemap(javaimports) Greeting * %{
import java.util.*; // for EventListener
import java.lang.*; // for Exception
%};

%typemap(javabase) Greeting * "Exception";
%typemap(javainterfaces) Greeting * "EventListener";
%typemap(javacode) Greeting * %{
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

// Create a new getCPtr() function which takes Java null
%typemap(javagetcptr) Farewell * %{
  public static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }
%}

// Make the pointer constructor public
%typemap(javaptrconstructormodifiers) Farewell * "public";


%{
class Greeting {};
class Farewell {};
%}

%inline %{
    Greeting* solong(Farewell* f) { return NULL; }
%}

