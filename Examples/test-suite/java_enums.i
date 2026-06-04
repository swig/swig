
// This testcase uses the %javaconst directive to control how enums are initialised

%module java_enums

%include "enumtypeunsafe.swg"

// Some pragmas to add in an interface to the module class
#ifdef SWIGJAVA_SOURCE
%pragma(java) moduleinterfaces="Serializable"
%pragma(java) moduleimports=%{
import java.io.*; // For Serializable
%}
%pragma(java) modulecode=%{
  public static final long serialVersionUID = 0x52151001; // Suppress ecj warning
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) moduleinterfaces="java.io.Serializable"
%pragma(java) modulecode=%{
  @JvmField public val serialVersionUID: Long = 0x52151001L // Suppress warning
%}
#endif


// Set default Java const code generation
%javaconst(1);

// Test enums with trailing comma after the last item.
enum WithTrailingComma
{
    First,
    Second,
};

%ignore ReallyFirstOneIsIgnored;
enum WithTrailingCommaAndIgnoredFirstItem
{
    ReallyFirstOneIsIgnored,
    FirstNonIgnoredOne,
    SecondNonIgnoredOne,
};

#ifdef SWIGJAVA_SOURCE
// Change the default generation so that these enums are generated into an interface instead of a class
%typemap(javaclassmodifiers) enum stuff "public interface"
#endif

%inline %{
enum stuff { FIDDLE = 2*100,  STICKS = 5+8, BONGO, DRUMS };
%}

// Check that the enum typemaps are working by using a short for the enums instead of int
%javaconst(0); // will create compile errors in runme file if short typemaps not used 

namespace Space {
#ifdef SWIGJAVA_SOURCE
%typemap(jtype) enum nonsense "short"
%typemap(jstype) enum nonsense "short"
#elif defined SWIGKOTLIN_SOURCE
%typemap(jtype) enum nonsense "Short"
%typemap(jstype) enum nonsense "Short"
#endif
%typemap(javain) enum nonsense "$javainput"
%typemap(in) enum nonsense %{ $1 = (enum Space::nonsense)$input; %}
%typemap(out) enum nonsense %{ $result = (jshort)$1; %}
%typemap(jni) enum nonsense "jshort"
%typemap(javaout) enum nonsense {
    return $jnicall;
  }
}

%inline %{
namespace Space {
enum nonsense { POPPYCOCK, JUNK };
nonsense test1(nonsense n) { return n; }
enum nonsense test2(enum nonsense n) { return n; }
}
%}

// Test the %javaconstvalue directive for enums
%{
static const int FOUR = 4;
%}

%javaconst(1);
%javaconstvalue(4) Quattro;
%inline %{
enum Numero { Quattro = FOUR };
%}

// Test boolean enums
%inline %{
typedef enum { PLAY = true, STOP = false } play_state;
%}

