/* 
   Auxiliary methods for assigning unnamed type C++ variables, where
   swig doesn't know the casting type, but C++ can derived it:

     struct Foo { enum {Hi, Hello } hola; };

   These are very specific macros, that could keep growing as more
   compilers require especial support, or could vanish latter if the
   enum mapping changes drastically. Therefore, better we put them in
   this separate file, so swig.swg doesn't change every time we update
   something here.

*/

%insert("runtime") %{
#ifdef __cplusplus
// here, the C++ compilers that do not accept unnamed template parameters 
#if defined(_SGI_COMPILER_VERSION)
//
// Activate the following macro for compilers that do not support
// unnamed template parameters, but where memcpy works.
//
#define SWIG_UNNAMED_USE_MEMCPY
//
//
#ifdef SWIG_UNNAMED_USE_MEMCPY
// "dangerous" assigment, but for enums it should work.
// it is dangerous because you could get a bad value,
// but it is safer than "*(T*)(void*)&x = t;", which
// could produce a seg. fault.
#define swig_assign_unnamed(eval, val) memcpy(&(eval),&(val), sizeof(eval))
#else
// much much safer choice :)
#define swig_assign_unnamed(eval, val) printf("unnamed member assigment not supported\n")
#endif
#else
template <class T, class V>
inline
void swig_assign_unnamed(T& eval, const V& val)
{
  // it 'should' be:  eval = static_cast<T>(val);
  // but just in case we found a very very old compiler
  eval = (T)val;
}
#endif
#else
#define swig_assign_unnamed(eval, val) eval = val
#endif
%}
