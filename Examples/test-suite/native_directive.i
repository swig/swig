%module native_directive

%{
#include <ctype.h>
int alpha_count(const char *instring) {
  int count = 0;
  const char *s = instring;
  while (s && *s) {
    if (isalpha((int)*s))
      count++;
    s++;
  };
  return count;
}
%}

%inline %{
int CountAlphas(const char *instring) {
  return alpha_count(instring);
}
%}

// Languages that support %native should code up language specific implementations below

#if defined(SWIGJAVA)
%native(CountAlphaCharacters) int alpha_count(const char *inputString);
%{
extern "C" JNIEXPORT jint JNICALL Java_native_1directive_native_1directiveJNI_CountAlphaCharacters(JNIEnv *jenv, jclass jcls, jstring instring) {
  jint jresult = 0 ;
  (void)jcls;

  if (instring) {
    const char *s = (char *)jenv->GetStringUTFChars(instring, 0);
    if (s) {
      jresult = (jint)alpha_count(s);
      jenv->ReleaseStringUTFChars(instring, s);
    }
  }
  return jresult;
}
%}
#endif


// TODO: C#
// TODO: Python


#ifdef SWIGJAVASCRIPT
%native(CountAlphaCharacters) void JavaScript_alpha_count();
%{
#ifdef SWIG_V8_VERSION /* engine = node || v8 */

static SwigV8ReturnValue JavaScript_alpha_count(const SwigV8Arguments &args) {
  SWIGV8_HANDLESCOPE();
  v8::Handle<v8::Value> jsresult;
  char *arg1 = (char *)0;
  int res1;
  char *buf1 = 0;
  int alloc1 = 0;
  int result;
  if(args.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for _wrap_alpha_count.");
  res1 = SWIG_AsCharPtrAndSize(args[0], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1))
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
  arg1 = reinterpret_cast< char * >(buf1);
  result = (int)alpha_count((char const *)arg1);
  jsresult = SWIG_From_int(static_cast< int >(result));
  if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
  SWIGV8_RETURN(jsresult);
fail:
  SWIGV8_RETURN(SWIGV8_UNDEFINED());
}

#else /* engine = jsc */

static JSValueRef JavaScript_alpha_count(JSContextRef context, JSObjectRef function,
  JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  char *arg1 = (char *)0;
  int res1;
  char *buf1 = 0;
  int alloc1 = 0;
  int result;
  JSValueRef jsresult;
  if (argc != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments.");
  res1 = SWIG_JSC_AsCharPtrAndSize(context, argv[0], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1))
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
  arg1 = reinterpret_cast< char * >(buf1);
  result = (int)alpha_count((char const *)arg1);
  jsresult = SWIG_From_int  SWIG_JSC_FROM_CALL_ARGS(static_cast< int >(result));
  if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
  return jsresult;
fail:
  return JSValueMakeUndefined(context);
}

#endif /* engine */
%}
#endif /* SWIGJAVASCRIPT */

