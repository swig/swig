#if defined(__GNUC__)
    typedef long long __int64; /*For gcc on Windows */
#endif
#include <jni.h>
#include <stdlib.h>

#ifdef __cplusplus
#define JCALL0(func, jenv) jenv->func()
#define JCALL1(func, jenv, ar1) jenv->func(ar1)
#define JCALL2(func, jenv, ar1, ar2) jenv->func(ar1, ar2)
#define JCALL3(func, jenv, ar1, ar2, ar3) jenv->func(ar1, ar2, ar3)
#define JCALL4(func, jenv, ar1, ar2, ar3, ar4) jenv->func(ar1, ar2, ar3, ar4)
#else
#define JCALL0(func, jenv) (*jenv)->func(jenv)
#define JCALL1(func, jenv, ar1) (*jenv)->func(jenv, ar1)
#define JCALL2(func, jenv, ar1, ar2) (*jenv)->func(jenv, ar1, ar2)
#define JCALL3(func, jenv, ar1, ar2, ar3) (*jenv)->func(jenv, ar1, ar2, ar3)
#define JCALL4(func, jenv, ar1, ar2, ar3, ar4) (*jenv)->func(jenv, ar1, ar2, ar3, ar4)
#endif
