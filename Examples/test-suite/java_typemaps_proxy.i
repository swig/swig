/* Tests the Java specific directives */

%module java_typemaps_proxy


%typemap(javaimports) SWIGTYPE "import java.math.*;";
%typemap(javacode) NS::Farewell %{
  public void saybye(BigDecimal num_times) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(javaclassmodifiers) NS::Farewell "public final class";

%typemap(javaimports) NS::Greeting %{
import java.util.*; // for EventListener
import java.lang.*; // for Exception
%};

%typemap(javabase) NS::Greeting "Exception";
%typemap(javainterfaces) NS::Greeting "EventListener";
%typemap(javacode) NS::Greeting %{
  // Pure Java code generated using %typemap(javacode) 
  public void sayhello() {
    hello();
  }

  public static void cheerio(EventListener e) {
  }
%}

// Create a new getCPtr() function which takes Java null and is public
%typemap(javabody) NS::Greeting %{
  private long swigCPtr;
  protected boolean swigCMemOwn;

  protected $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  public static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }
%}

// Make the pointer constructor public
%typemap(javabody) NS::Farewell %{
  private long swigCPtr;
  protected boolean swigCMemOwn;

  public $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }
%}

// get rid of the finalize method for NS::Farewell
%typemap(javafinalize) NS::Farewell "";

// Test typemaps are being found for templated classes
%typemap(javacode) NS::Adieu<int**> %{
  public static void adieu() {
  }
%}

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


