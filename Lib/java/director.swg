/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to Java extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#if defined(DEBUG_DIRECTOR_OWNED)
#include <iostream>
#endif

#include <exception>

namespace Swig {

  /* Java object wrapper */
  class JObjectWrapper {
  public:
    JObjectWrapper() : jthis_(NULL), weak_global_(true) {
    }

    ~JObjectWrapper() {
      jthis_ = NULL;
      weak_global_ = true;
    }

    bool set(JNIEnv *jenv, jobject jobj, bool mem_own, bool weak_global) {
      if (!jthis_) {
        weak_global_ = weak_global || !mem_own; // hold as weak global if explicitly requested or not owned
        if (jobj)
          jthis_ = weak_global_ ? jenv->NewWeakGlobalRef(jobj) : jenv->NewGlobalRef(jobj);
#if defined(DEBUG_DIRECTOR_OWNED)
        std::cout << "JObjectWrapper::set(" << jobj << ", " << (weak_global ? "weak_global" : "global_ref") << ") -> " << jthis_ << std::endl;
#endif
        return true;
      } else {
#if defined(DEBUG_DIRECTOR_OWNED)
        std::cout << "JObjectWrapper::set(" << jobj << ", " << (weak_global ? "weak_global" : "global_ref") << ") -> already set" << std::endl;
#endif
        return false;
      }
    }

    jobject get(JNIEnv *jenv) const {
#if defined(DEBUG_DIRECTOR_OWNED)
      std::cout << "JObjectWrapper::get(";
      if (jthis_)
        std::cout << jthis_;
      else
        std::cout << "null";
      std::cout << ") -> return new local ref" << std::endl;
#endif
      return (jthis_ ? jenv->NewLocalRef(jthis_) : jthis_);
    }

    void release(JNIEnv *jenv) {
#if defined(DEBUG_DIRECTOR_OWNED)
      std::cout << "JObjectWrapper::release(" << jthis_ << "): " << (weak_global_ ? "weak global ref" : "global ref") << std::endl;
#endif
      if (jthis_) {
        if (weak_global_) {
          if (jenv->IsSameObject(jthis_, NULL) == JNI_FALSE)
            jenv->DeleteWeakGlobalRef((jweak)jthis_);
        } else
          jenv->DeleteGlobalRef(jthis_);
      }

      jthis_ = NULL;
      weak_global_ = true;
    }

    /* Only call peek if you know what you are doing wrt to weak/global references */
    jobject peek() {
      return jthis_;
    }

    /* Java proxy releases ownership of C++ object, C++ object is now
       responsible for destruction (creates NewGlobalRef to pin Java proxy) */
    void java_change_ownership(JNIEnv *jenv, jobject jself, bool take_or_release) {
      if (take_or_release) {  /* Java takes ownership of C++ object's lifetime. */
        if (!weak_global_) {
          jenv->DeleteGlobalRef(jthis_);
          jthis_ = jenv->NewWeakGlobalRef(jself);
          weak_global_ = true;
        }
      } else {
	/* Java releases ownership of C++ object's lifetime */
        if (weak_global_) {
          jenv->DeleteWeakGlobalRef((jweak)jthis_);
          jthis_ = jenv->NewGlobalRef(jself);
          weak_global_ = false;
        }
      }
    }

  private:
    /* pointer to Java object */
    jobject jthis_;
    /* Local or global reference flag */
    bool weak_global_;
  };

  /* director base class */
  class Director {
    /* pointer to Java virtual machine */
    JavaVM *swig_jvm_;

  protected:
#if defined (_MSC_VER) && (_MSC_VER<1300)
    class JNIEnvWrapper;
    friend class JNIEnvWrapper;
#endif
    /* Utility class for managing the JNI environment */
    class JNIEnvWrapper {
      const Director *director_;
      JNIEnv *jenv_;
      int env_status;
    public:
      JNIEnvWrapper(const Director *director) : director_(director), jenv_(0), env_status(0) {
#if defined(__ANDROID__)
        JNIEnv **jenv = &jenv_;
#else
        void **jenv = (void **)&jenv_;
#endif
        env_status = director_->swig_jvm_->GetEnv((void **)&jenv_, JNI_VERSION_1_2);
#if defined(SWIG_JAVA_ATTACH_CURRENT_THREAD_AS_DAEMON)
        // Attach a daemon thread to the JVM. Useful when the JVM should not wait for 
        // the thread to exit upon shutdown. Only for jdk-1.4 and later.
        director_->swig_jvm_->AttachCurrentThreadAsDaemon(jenv, NULL);
#else
        director_->swig_jvm_->AttachCurrentThread(jenv, NULL);
#endif
      }
      ~JNIEnvWrapper() {
#if !defined(SWIG_JAVA_NO_DETACH_CURRENT_THREAD)
        // Some JVMs, eg jdk-1.4.2 and lower on Solaris have a bug and crash with the DetachCurrentThread call.
        // However, without this call, the JVM hangs on exit when the thread was not created by the JVM and creates a memory leak.
        if (env_status == JNI_EDETACHED)
          director_->swig_jvm_->DetachCurrentThread();
#endif
      }
      JNIEnv *getJNIEnv() const {
        return jenv_;
      }
    };

    /* Java object wrapper */
    JObjectWrapper swig_self_;

    /* Disconnect director from Java object */
    void swig_disconnect_director_self(const char *disconn_method) {
      JNIEnvWrapper jnienv(this) ;
      JNIEnv *jenv = jnienv.getJNIEnv() ;
      jobject jobj = swig_self_.get(jenv);
#if defined(DEBUG_DIRECTOR_OWNED)
      std::cout << "Swig::Director::disconnect_director_self(" << jobj << ")" << std::endl;
#endif
      if (jobj && jenv->IsSameObject(jobj, NULL) == JNI_FALSE) {
        jmethodID disconn_meth = jenv->GetMethodID(jenv->GetObjectClass(jobj), disconn_method, "()V");
        if (disconn_meth) {
#if defined(DEBUG_DIRECTOR_OWNED)
          std::cout << "Swig::Director::disconnect_director_self upcall to " << disconn_method << std::endl;
#endif
          jenv->CallVoidMethod(jobj, disconn_meth);
        }
      }
      jenv->DeleteLocalRef(jobj);
    }

  public:
    Director(JNIEnv *jenv) : swig_jvm_((JavaVM *) NULL), swig_self_() {
      /* Acquire the Java VM pointer */
      jenv->GetJavaVM(&swig_jvm_);
    }

    virtual ~Director() {
      JNIEnvWrapper jnienv(this) ;
      JNIEnv *jenv = jnienv.getJNIEnv() ;
      swig_self_.release(jenv);
    }

    bool swig_set_self(JNIEnv *jenv, jobject jself, bool mem_own, bool weak_global) {
      return swig_self_.set(jenv, jself, mem_own, weak_global);
    }

    jobject swig_get_self(JNIEnv *jenv) const {
      return swig_self_.get(jenv);
    }

    // Change C++ object's ownership, relative to Java
    void swig_java_change_ownership(JNIEnv *jenv, jobject jself, bool take_or_release) {
      swig_self_.java_change_ownership(jenv, jself, take_or_release);
    }
  };


  // Utility methods and classes for exception handling.

  // Helper method to determine if a Java throwable matches a particular Java class type
  bool ExceptionMatches(JNIEnv *jenv, jthrowable excp, const char *clzname) {
    jboolean matches = false;

    if (excp && jenv && clzname) {
      // Exceptions need to be cleared for correct behavior.
      // The caller of ExceptionMatches should restore pending exceptions if desired - 
      // the caller already has the throwable.
      jenv->ExceptionClear();

      jclass clz = jenv->FindClass(clzname);
      if (clz && !jenv->ExceptionCheck()) {
	jclass classclz = jenv->GetObjectClass(clz);
	jmethodID isInstanceMethodID = jenv->GetMethodID(classclz, "isInstance", "(Ljava/lang/Object;)Z");
	if (isInstanceMethodID) {
	  matches = (jboolean)jenv->CallBooleanMethod(clz, isInstanceMethodID, excp);
	}
      }
      // This may happen if user typemaps or director:except
      // features call ExceptionMatches incorrectly, typically with
      // an invalid clzname argument.  Uncommenting the debug lines
      // may help to diagnose.
      // As is, this leaves the underlying case as a pending exception
      // which may not be that clear (e.g. ClassNotFoundException)

      // if (jenv->ExceptionCheck()) {
      // JavaExceptionMessage jstrmsg(jenv, jenv->ExceptionOccurred());
      // std::cerr << "Error: ExceptionMatches: class '" <<
      //   clzname << "' : " << jstrmsg.message() << std::endl;
      // }
    }
    return matches;
  }

  // Simple holder for a Java string during exception handling, allowing access to a c-style string
  class JavaString {
  public:
    JavaString(JNIEnv *jenv, jstring jstr) : jenv_(jenv), jstr_(jstr), cstr_(0) {
      if (jenv_ && jstr_)
	cstr_ = (const char *) jenv_->GetStringUTFChars(jstr_, NULL);
    }

    ~JavaString() {
      if (jenv_ && jstr_ && cstr_)
	jenv_->ReleaseStringUTFChars(jstr_, cstr_);
    }

    const char *cstr() {
      return cstr_ ? cstr_ : "";
    }

  private:
    // non-copyable
    JavaString(const JavaString &);
    JavaString &operator=(const JavaString &);

    JNIEnv *jenv_;
    jstring jstr_;
    const char *cstr_;
  };

  // Helper to extract the exception message from a Java throwable
  class JavaExceptionMessage {
  public:
    JavaExceptionMessage(JNIEnv *jenv, jthrowable excp) : jstrholder_(jenv, exceptionMsgJstr(jenv, excp)) {
    }

    ~JavaExceptionMessage() {
    }

    const char *message() {
      return jstrholder_.cstr();
    }

  private:
    // non-copyable
    JavaExceptionMessage(const JavaExceptionMessage &);
    JavaExceptionMessage &operator=(const JavaExceptionMessage &);

    // Static method to initialize jstrholder_
    static jstring exceptionMsgJstr(JNIEnv *jenv, jthrowable excp) {
      jstring jmsg = NULL;
      if (jenv && excp) {
	jenv->ExceptionClear(); // Cannot invoke methods with pending exception
	jclass thrwclz = jenv->GetObjectClass(excp);
	if (thrwclz) {
	  // if no getMessage() or other exception, no msg available.
	  jmethodID getThrowableMsgMethodID = jenv->GetMethodID(thrwclz, "getMessage", "()Ljava/lang/String;");
	  if (getThrowableMsgMethodID && !jenv->ExceptionCheck()) {
	    // if problem accessing exception message string, no msg will be available.
	    jmsg = (jstring)jenv->CallObjectMethod(excp, getThrowableMsgMethodID);
	  }
	}
	if (jmsg == NULL && jenv->ExceptionCheck()) {
	  jenv->ExceptionClear();
	}
      }
      return jmsg;
    }

    JavaString jstrholder_;
  };

  // C++ Exception class for converting from Java exceptions thrown during a director method Java upcall
  class DirectorException : public std::exception {
  public:

    // Construct a DirectorException from a Java throwable
    DirectorException(JNIEnv *jenv, jthrowable excp) : classname_(0), msg_(0) {
      jstring jstr_classname = NULL;

      if (excp) {
	// Get the exception class, like Exception
	jclass thrwclz = jenv->GetObjectClass(excp);
	if (thrwclz) {
	  // Get the Java.lang.Class class
	  jclass clzclz = jenv->GetObjectClass(thrwclz);
	  if (clzclz) {
	    jmethodID mid_getName = mid_getName = jenv->GetMethodID(clzclz, "getName", "()Ljava/lang/String;");
	    if (mid_getName) {
	      // Get the excp class name
	      jstr_classname = (jstring)(jenv->CallObjectMethod(thrwclz, mid_getName));
	    }
	  }
	}
      }
      // Copy strings, since no guarantee jenv will be active when handled
      // If classname_ is 0, returned as "UnknownException"
      if (jstr_classname) {
	JavaString classname(jenv, jstr_classname);
	classname_ = copypath(classname.cstr());
      }
      JavaExceptionMessage exceptionmsg(jenv, excp);
      msg_ = copystr(exceptionmsg.message());
    }

    // Throw as a wrapped RuntimeError explicitly.
    DirectorException(const char *msg) : classname_(0), msg_(0) {
      classname_ = copypath("java/lang/RuntimeError");
      msg_ = copystr(msg);
    }

    ~DirectorException() throw() {
      delete[] classname_;
      delete[] msg_;
    }

    // If there was a problem finding classname, keep track of error
    // On raiseJavaException will be mapped to a RuntimeException
    const char *classname() const throw() {
      return classname_ ? classname_ : "UnknownException";
    }

    const char *what() const throw() {
      return msg_ ? msg_ : "";
    }

    // Reconstruct and raise the Java Exception that caused the DirectorException
    void raiseJavaException(JNIEnv *jenv) {
      if (jenv) {
	jenv->ExceptionClear();

	jmethodID strCtorID = 0;
	jclass excpclz = jenv->FindClass(classname());

	if (excpclz) {
	  strCtorID = jenv->GetMethodID(excpclz,"<init>","(Ljava/lang/String;)V");
	}

	if (strCtorID) {
	  // If exception has a string constructor, throw an instance
	  jenv->ThrowNew(excpclz, what());
	} else {
	  // Else, throw a runtime
	  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, what() );
	}
      }
    }

  private:
    static const char *copypath(const char *srcmsg) {
      return copystr(srcmsg, 1);
    }

    static const char *copystr(const char *srcmsg, int pathrepl=0) {
      char *target = 0;
      if (srcmsg) {
	int msglen = 1 + strlen(srcmsg);
	target = new char[msglen];
	strncpy(target, srcmsg, msglen);
      }
      // If pathrepl, replace any '.' with '/'
      if (pathrepl) {
	for (char *c=target; *c; ++c) {
	  if ('.' == *c)
	    *c = '/';
	}
      }
      return target;
    }

    const char *classname_;
    const char *msg_;
  };

}

#endif /* __cplusplus */
