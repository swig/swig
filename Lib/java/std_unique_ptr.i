/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * The typemaps here allow handling functions returning std::unique_ptr<>,
 * which is the most common use of this type. If you have functions taking it
 * as parameter, these typemaps can't be used for them and you need to do
 * something else (e.g. use shared_ptr<> which SWIG supports fully).
 * ----------------------------------------------------------------------------- */

%define %unique_ptr(TYPE)

%typemap (jni) std::unique_ptr< TYPE > "jlong"
%typemap (jtype) std::unique_ptr< TYPE > "long"
%typemap (jstype) std::unique_ptr< TYPE > "$typemap(jstype, TYPE)"

%typemap(in) std::unique_ptr< TYPE > (TYPE *unique_temp)
%{ unique_temp = *(TYPE **)&$input;
  $1.reset(unique_temp); %}

%typemap(javain) std::unique_ptr< TYPE > "$typemap(jstype, TYPE).swigRelease($javainput)"

%typemap (out) std::unique_ptr< TYPE > %{
   jlong lpp = 0;
   *(TYPE **) &lpp = $1.release();
   $result = lpp;
%}

%typemap(javaout) std::unique_ptr< TYPE > {
     long cPtr = $jnicall;
     return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
   }

%typemap(javarelease) TYPE %{
  protected static long swigRelease($javaclassname obj) {
    long ptr = 0;
    if (obj != null) {
      if (!obj.swigCMemOwn)
        throw new RuntimeException("Cannot release ownership as memory is not owned");
      ptr = obj.swigCPtr;
      obj.swigCMemOwn = false;
      obj.delete();
    }
    return ptr;
  }
%}

%template() std::unique_ptr< TYPE >;
%enddef

namespace std {
   template <class T> class unique_ptr {};
} 
