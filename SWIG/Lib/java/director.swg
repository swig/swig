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

protected:
  /* pointer to the wrapped java object */
  jobject	__self;
  /* ricochet flag: Prevent user from shooting themselves in the
     foot by detecting recursive upcall */
  bool		__ricochet;

  /* Acquire Java VM environment from Java VM */
  JNIEnv *__acquire_jenv() const {
    JNIEnv *env;
    assert(__jvm);
    __jvm->AttachCurrentThread((void **) &env, NULL);
    return env;
  }

public:
  /* the default constructor should not be called */
  __DIRECTOR__() : __jvm(NULL), __self(NULL), __ricochet(false) { 
    assert(0); 
  }
  
  /* Default constructor */
  __DIRECTOR__(JNIEnv *jenv):
    __jvm((JavaVM *) NULL),
    __self(NULL),
    __ricochet(false)
  {
    /* Acquire the Java VM pointer */
    jenv->GetJavaVM(&__jvm);
  }

  /* Remove the Java object global lock at destruction */
  virtual ~__DIRECTOR__()
  {
    if (__self) {
      JNIEnv     *jenv;
      
      jenv = __acquire_jenv();
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

  /* Get ricochet flag, resetting it on the way out */
  inline bool __get_ricochet()
  {
    bool	__r = __ricochet;
    __ricochet = false;
    return __r;
  }

  /* Set the ricochet flag */
  inline void __set_ricochet()
  { __ricochet = true; }

  /* Clear the ricochet flag */
  inline void __clear_ricochet()
  { __ricochet = false; }
};

#endif /* __cplusplus */


