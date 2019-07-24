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

