/***********************************************************************
 * director.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Java extensions.
 *
 * Author : Scott Michel (scottm@aero.org)
 *
 * This file was adapted from the python director.swg, written by
 * Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

#ifdef __cplusplus

namespace Swig {
  /* director base class */
  class Director {
    private:
      /* pointer to Java virtual machine */
      JavaVM *swig_jvm;

    protected:
      /* pointer to the wrapped Java object */
      jobject swig_self;

      /* Acquire Java VM environment from Java VM */
      JNIEnv *swig_acquire_jenv() const {
        JNIEnv *env = NULL;
        swig_jvm->AttachCurrentThread((void **) &env, NULL);
        return env;
      }

      /* Disconnect director from Java object */
      void swig_disconnect_director_self(const char *disconn_method) {
        if (swig_self) {
          JNIEnv *jenv = swig_acquire_jenv();
          jmethodID disconn_meth = jenv->GetMethodID(jenv->GetObjectClass(swig_self), disconn_method, "()V");
          if (disconn_meth) {
            jenv->CallVoidMethod(swig_self, disconn_meth);
          } else {
            jenv->ExceptionClear();
          }
          jenv->DeleteGlobalRef(swig_self);
          swig_self = (jobject) NULL;
        }
      }

    public:
      Director(JNIEnv *jenv) : swig_jvm((JavaVM *) NULL), swig_self(NULL) {
        /* Acquire the Java VM pointer */
        jenv->GetJavaVM(&swig_jvm);
      }

      virtual ~Director() {
      }

      /* Set swig_self and get Java global reference on object */
      void swig_set_self(JNIEnv *jenv, jobject jself) {
        swig_self = jenv->NewGlobalRef(jself);
      }

      /* return a pointer to the wrapped Java object */
      jobject swig_get_self() const {
        return swig_self; 
      }
  };
}

#endif /* __cplusplus */


