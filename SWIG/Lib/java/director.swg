/***********************************************************************
 * director.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Java extensions.
 *
 * Author : Scott Michel (scottm@aero.org)
 *
 * N.B.: This file was
   adapted from the python director.swg, written by
 * Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

#ifdef __cplusplus

/* director base class */
class __DIRECTOR__ {
private:
  /* pointer to java virtual machine */
  JavaVM       *__jvm;
  /* the default constructor should not be called */
  __DIRECTOR__();

protected:
  /* pointer to the wrapped java object */
  jobject	__self;
  /* Acquire Java VM environment from Java VM */
  JNIEnv *__acquire_jenv() const {
    JNIEnv *env;
    assert(__jvm);
    __jvm->AttachCurrentThread((void **) &env, NULL);
    return env;
  }

public:
  /* Default constructor */
  __DIRECTOR__(JNIEnv *jenv):
    __jvm((JavaVM *) NULL),
    __self(NULL)
  {
    /* Acquire the Java VM pointer */
    jenv->GetJavaVM(&__jvm);
  }

  /* Remove the Java object global lock at destruction */
  virtual ~__DIRECTOR__()
  {
    if (__self) {
      JNIEnv           *jenv;
      jmethodID         disconn_meth;
      
      jenv = __acquire_jenv();
      disconn_meth = jenv->GetMethodID(jenv->GetObjectClass(__self), "__director_disconnect", "()V");
      if (disconn_meth)
        jenv->CallVoidMethod(__self, disconn_meth);
      jenv->DeleteGlobalRef(__self);
      __self = (jobject) NULL;
    }
  }
  
  /* Set __self and get Java global reference on object */
  inline void __set_self(JNIEnv *jenv, jobject jself)
  {
    __self = jenv->NewGlobalRef(jself);
  }

  /* return a pointer to the wrapped java object */
  inline jobject __get_self() const
  { return __self; }
};

#endif /* __cplusplus */


