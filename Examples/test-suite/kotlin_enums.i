
// This testcase uses the %kotlinconst directive to control how enums are initialised

%module kotlin_enums

%include "enumtypeunsafe.swg"

// Some pragmas to add in an interface to the module object
%pragma(kotlin) moduleinterfaces="java.io.Serializable"
%pragma(kotlin) modulecode=%{
  @JvmField public val serialVersionUID: Long = 0x52151001L // Suppress warning
%}


// Set default Kotlin const code generation
%kotlinconst(1);

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

%inline %{
enum stuff { FIDDLE = 2*100,  STICKS = 5+8, BONGO, DRUMS };
%}

// Check that the enum typemaps are working by using a short for the enums instead of int
%kotlinconst(0); // values come from a JNI call rather than a constant expression

namespace Space {
%typemap(ktype) enum nonsense "Short"
%typemap(kstype) enum nonsense "Short"
%typemap(kin) enum nonsense "$kotlininput"
%typemap(in) enum nonsense %{ $1 = (enum Space::nonsense)$input; %}
%typemap(out) enum nonsense %{ $result = (jshort)$1; %}
%typemap(jni) enum nonsense "jshort"
%typemap(kout) enum nonsense {
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

// Test the %kotlinconstvalue directive for enums
%{
static const int FOUR = 4;
%}

%kotlinconst(1);
%kotlinconstvalue(4) Quattro;
%inline %{
enum Numero { Quattro = FOUR };
%}

// Test boolean enums
%inline %{
typedef enum { PLAY = true, STOP = false } play_state;
%}
