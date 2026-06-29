
// Test case uses the Kotlin pragmas which are for tailoring the generated JNI class and Kotlin module object.

%module kotlin_pragmas

%pragma(kotlin) jniclassimports=%{
import java.io.Serializable
%}

// The JNI class is a Kotlin object. Make it public (default is internal-ish object access)
// and add an interface so the jniclass* pragmas are exercised. A Kotlin object cannot extend
// an arbitrary class with constructors, so unlike the Java test (jniclassbase="Exception")
// we only attach an interface here.
%pragma(kotlin) jniclassclassmodifiers="public object"
%pragma(kotlin) jniclassinterfaces="java.io.Serializable"

%pragma(kotlin) jniclasscode=%{
  // jniclasscode pragma code: load the C++ DLL/shared object when the object is initialised
  init {
    try {
      System.loadLibrary("kotlin_pragmas")
    } catch (e: UnsatisfiedLinkError) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
      kotlin.system.exitProcess(1)
    }
  }
  @JvmField val serialVersionUID: Long = 0x52151000L // Suppress warning
%}


%pragma(kotlin) moduleimports=%{
import java.io.Serializable
%}

// The module is a Kotlin object too; make it public and add the Serializable interface.
// A Kotlin object cannot have a base class with a constructor, so unlike the Java test
// (modulebase="Object") we only add an interface here.
%pragma(kotlin) moduleclassmodifiers="public object"
%pragma(kotlin) moduleinterfaces="java.io.Serializable"

%pragma(kotlin) modulecode=%{
  @JvmField val serialVersionUID: Long = 0x52151001L // Suppress warning
  fun added_function(s: String) {
    // Added function
  }
%}


%inline %{
int *get_int_pointer() {
    static int number = 10;
    return &number;
}
%}
