#include <jni.h>
#include <stdlib.h>

#ifdef __cplusplus
#define JCALL(func, jenv) jenv->func(
#else
#define JCALL(func, jenv) (*jenv)->func(jenv,
#endif

