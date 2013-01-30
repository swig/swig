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
       responsible for destruction (creates NewGlobalRef to pin Java
       proxy) */
    void java_change_ownership(JNIEnv *jenv, jobject jself, bool take_or_release) {
      if (take_or_release) {  /* Java takes ownership of C++ object's lifetime. */
        if (!weak_global_) {
          jenv->DeleteGlobalRef(jthis_);
          jthis_ = jenv->NewWeakGlobalRef(jself);
          weak_global_ = true;
        }
      } else { /* Java releases ownership of C++ object's lifetime */
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
}

// Default exception handler for all director methods.
// Can override this for specific methods
// This just documents the default.  It is not actually attached as a feature
// for efficiency reasons (and is defined in java.cxx)  It can be overridden
// as a feature for specific methods or globally.  The default handler can also
// be overridden for specific methods or globally, as %feature("director:except:defaulthandler")
//%feature("director:except",defaulthandler="") %{
//  jthrowable $error = jenv->ExceptionOccurred();
//  if ($error) {
//    jenv->ExceptionClear();
//    $directorthrowshandlers
//    $defaulthandler
//    /* If neither default handler or throws handlers raised a C++ exception
//       set the java exception active again for backwards compatibility */
//    jenv->Throw(jthrowable);
//    return $null;
//  }
//%}

// Define some utility methods and classes.  Cannot use fragments since these are used by %features
// and in directorthrows typemaps

#include <exception>

// Simple holder for exception messages, allowing access to a c-style string
namespace Swig {
  struct JavaExceptionMessage {

    JavaExceptionMessage(JNIEnv *jenv, jthrowable excp) : jenv_(jenv), jmsg_(0), cstr_(0) {
      // No message, unexpected inputs.  assert, warn or something instead?
      if (!jenv_ || !excp) return; 
      jenv_ -> ExceptionClear();  // Cannot invoke other methods with pending exception

      jclass thrwclz = jenv->GetObjectClass(excp);
      // if no getMessage method or other exception, no msg available.  As above.
      jmethodID getThrowableMessageMethodID = jenv_->GetMethodID(
         thrwclz, "getMessage", "()Ljava/lang/String;");
      if (jenv_->ExceptionCheck() || !getThrowableMessageMethodID) {
        jenv_ -> ExceptionClear();
	return;
      }

      // if problem accessing exception message string, no msg available.  As above.
      jmsg_ = (jstring)jenv_->CallObjectMethod(excp, getThrowableMessageMethodID);
      if (jenv_->ExceptionCheck() || !jmsg_) {
        jenv_ -> ExceptionClear();
        return;
      }

      // Get the null-terminated c-string out, and hold it
      //TODO: handle better for non-ascii?  Need encoding and wchar std::wstring ...
      cstr_ = (const char *)jenv_->GetStringUTFChars(jmsg_, NULL);
    };

    ~JavaExceptionMessage() {
      if (jenv_ && jmsg_ && cstr_) {
	jenv_->ReleaseStringUTFChars(jmsg_,cstr_);
      }
    }
    
    const char *message() {
      return cstr_?cstr_:"";
    }

  private:
    // non-copyable
    JavaExceptionMessage(const JavaExceptionMessage&);
    JavaExceptionMessage& operator=(const JavaExceptionMessage&);
    const char *cstr_;
    JNIEnv* jenv_;
    jstring jmsg_;
  };

  // function to resolve this methodID, once
  jmethodID Class_isInstanceMethod(JNIEnv *jenv) {
    jclass classclz = jenv->FindClass("java/lang/Class");
    if (jenv->ExceptionCheck() || !classclz) {
      jenv -> ExceptionClear();
      return 0;
    }
    jmethodID isClassInstanceMethodID =
      jenv->GetMethodID(classclz, "isInstance", "(Ljava/lang/Object;)Z");
    if (jenv->ExceptionCheck() || !isClassInstanceMethodID)  {
      jenv -> ExceptionClear();
      return 0;
    }
    return isClassInstanceMethodID;
  }

  // utility function to simplify testing and mapping exceptions
  bool ExceptionMatches(JNIEnv *jenv, jthrowable excp, const char * otherclassname) {
    if (!excp) return false;  // No exception occurred
    if (!jenv) return false;  // unexpected, no jenv passed
    // static: Only lookup isInstance method once.
 
    // Have to clear exceptions for correct behavior.  Code around ExceptionMatches
    //   should restore pending exception if desired - obviously have throwable.
    jenv -> ExceptionClear();    

    static jmethodID isInstanceMethodID = Class_isInstanceMethod(jenv);
    if (!isInstanceMethodID) return false;

    jclass other = jenv->FindClass(otherclassname);
    if (jenv->ExceptionCheck() || !other) {
      // TODO: warn at runtime ?
      //If otherclassname not found, false. Uncomment and add iostream include to debug ExceptionMatches.
      //std::cerr<< "Error: ExceptionMatch '" << otherclassname << "': class not found"  << std::endl;
      jenv -> ExceptionClear();
      return false;
    }

    jboolean matches =
      (jboolean)jenv->CallBooleanMethod(other, isInstanceMethodID, excp);
    if (jenv->ExceptionCheck()) {
      jenv -> ExceptionClear();
      return false;
    }
    return matches;
  }
}

#endif /* __cplusplus */
