
// Test case uses all the Java pragmas which are for tailoring the generated JNI class and Java module class.

%module java_pragmas

#ifdef SWIGJAVA_SOURCE
%pragma(java) jniclassimports=%{
import java.lang.*; // For Exception
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) jniclassimports=%{
import java.io.Serializable
%}
#endif

#ifdef SWIGJAVA_SOURCE
%pragma(java) jniclassclassmodifiers="public class"
%pragma(java) jniclassbase="Exception"
%pragma(java) jniclassinterfaces="Cloneable"
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) jniclassclassmodifiers="public object"
%pragma(java) jniclassinterfaces="java.io.Serializable"
#endif

#ifdef SWIGJAVA_SOURCE
%pragma(java) jniclasscode=%{
  // jniclasscode pragma code: Static block so that the JNI class loads the C++ DLL/shared object when the class is loaded
  static {
    try {
	  System.loadLibrary("java_pragmas");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  public static final long serialVersionUID = 0x52151000; // Suppress ecj warning
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) jniclasscode=%{
  // jniclasscode pragma code: load the C++ DLL/shared object when the object is initialised
  init {
    try {
      System.loadLibrary("java_pragmas")
    } catch (e: UnsatisfiedLinkError) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
      kotlin.system.exitProcess(1)
    }
  }
  @JvmField val serialVersionUID: Long = 0x52151000L // Suppress warning
%}
#endif


#ifdef SWIGJAVA_SOURCE
%pragma(java) moduleimports=%{
import java.io.*; // For Serializable
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) moduleimports=%{
import java.io.Serializable
%}
#endif

#ifdef SWIGJAVA_SOURCE
%pragma(java) moduleclassmodifiers="public final class"
%pragma(java) modulebase="Object"
%pragma(java) moduleinterfaces="Serializable"
#endif

#ifdef SWIGJAVA_SOURCE
%pragma(java) modulecode=%{
  public static final long serialVersionUID = 0x52151001; // Suppress ecj warning
  public static void added_function(String s) {
    // Added function
  }
%}
#elif defined SWIGKOTLIN_SOURCE
%pragma(java) moduleclassmodifiers="public object"
%pragma(java) moduleinterfaces="java.io.Serializable"

%pragma(java) modulecode=%{
  @JvmField val serialVersionUID: Long = 0x52151001L // Suppress warning
  @Suppress("UNUSED_PARAMETER")
  fun added_function(s: String) {
    // Added function
  }
%}
#endif


%inline %{
int *get_int_pointer() {
    static int number = 10;
    return &number;
}
%}

