/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * The typemaps here allow handling functions returning std::unique_ptr<>,
 * which is the most common use of this type. If you have functions taking it
 * as parameter, these typemaps can't be used for them and you need to do
 * something else (e.g. use shared_ptr<> which SWIG supports fully).
 * ----------------------------------------------------------------------------- */

%define %unique_ptr(TYPE)
%typemap (ctype) std::unique_ptr< TYPE > "void *"
%typemap (imtype, out="System.IntPtr") std::unique_ptr< TYPE > "global::System.Runtime.InteropServices.HandleRef"
%typemap (cstype) std::unique_ptr< TYPE > "$typemap(cstype, TYPE)"

%typemap(in) std::unique_ptr< TYPE >
%{ $1.reset((TYPE *)$input); %}

%typemap(csin) std::unique_ptr< TYPE > "$typemap(cstype, TYPE).swigRelease($csinput)"

%typemap (out) std::unique_ptr< TYPE > %{
   $result = (void *)$1.release();
%}
%typemap(csout, excode=SWIGEXCODE) std::unique_ptr< TYPE > {
     System.IntPtr cPtr = $imcall;
     $typemap(cstype, TYPE) ret = (cPtr == System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
     return ret;
   }
%template() std::unique_ptr< TYPE >;
%enddef

namespace std {
  template <class T> class unique_ptr {};
} 
