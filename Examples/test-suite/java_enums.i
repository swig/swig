
// This testcase uses the %javaconst directive to control how enums are initialised

%module java_enums

%include "enumtypeunsafe.swg"

// Some pragmas to add in an interface to the module class
%pragma(java) moduleinterfaces="Serializable"
%pragma(java) moduleimports=%{
import java.io.*; // For Serializable
%}

// Set default Java const code generation
%javaconst(1);

// Change the default generation so that these enums are generated into an interface instead of a class
%typemap(javaclassmodifiers) enum stuff "public interface"

%inline %{
enum stuff { FIDDLE = 2*100,  STICKS = 5+8, BONGO, DRUMS };
%}

// Check that the enum typemaps are working by using a short for the enums instead of int
%javaconst(0); // will create compile errors in runme file if short typemaps not used 
%typemap(jtype) enum nonsense "short"
%typemap(jstype) enum nonsense "short"
%typemap(javain) enum nonsense "$javainput"
%typemap(in) enum nonsense %{ $1 = (short)$input; %}
%typemap(out) enum nonsense %{ $result = (jshort)$1; %}
%typemap(jni) enum nonsense "jshort"
%typemap(javaout) enum nonsense {
    return $jnicall;
  }

%inline %{
enum nonsense { POPPYCOCK, JUNK };
nonsense test1(nonsense n) { return n; }
enum nonsense test2(enum nonsense n) { return n; }
%}
