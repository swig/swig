/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to Java extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include <string>

#include <iostream>

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

    // These methods are always called in the context of an active JNIenv in director
    //   method dispatch
    std::string GetMessage(JNIEnv *jenv, jthrowable excp) {
       std::string rslt;
       if (!jenv || !excp) return rslt;  // no exception or unexpected call parameters
       
       jclass thrwclz = jenv->GetObjectClass(excp);
       if (jenv->ExceptionCheck() || !thrwclz) {
         std::cerr<< "Unexpected error: Could not get class of thrown exception" << std::endl;
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jmethodID getThrowableMessageMethodID = jenv->GetMethodID(thrwclz, "getMessage", "()Ljava/lang/String;");
       if (jenv->ExceptionCheck() || !getThrowableMessageMethodID) {
         std::cerr<< "Unexpected error: Could not find getMessage on thrown exception class" << std::endl;
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jstring jmsg = (jstring)jenv->CallObjectMethod(excp, getThrowableMessageMethodID);
       if (jenv->ExceptionCheck()) {
         std::cerr<< "Unexpected error: error calling getMessage on exception" << std::endl;
 	 jenv -> ExceptionClear();
       }
       // Returned message could be null (unexpected)
       if (!jmsg) {
         std::cerr<< "Unexpected error: getMessage returned null" << std::endl;
 	 return rslt;
       }

       //TODO: handle better for non-ascii?  Need encoding and wchar std::wstring ...
       rslt = GetStdString(jenv, jmsg);
       return rslt;
    }

    // Used to report improper exception translation
    std::string GetClassName(JNIEnv *jenv, jthrowable excp) {
       std::string rslt;
       if (!jenv || !excp) return rslt;  // no exception or unexpected call parameters
       
       jclass thrwclz = jenv->GetObjectClass(excp);
       jclass classclz = jenv->FindClass("java/lang/Class");

       jmethodID getNameMethodID = jenv->GetMethodID(classclz, "getName", "()Ljava/lang/String;");
       if (jenv->ExceptionCheck() || !getNameMethodID) {
         std::cerr<< "Unexpected error: Could not find getName on java/lang/Class" << std::endl;
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jstring jmsg = (jstring)jenv->CallObjectMethod(thrwclz, getNameMethodID);
       if (jenv->ExceptionCheck()) {
         std::cerr<< "Unexpected error: error calling Class.getName on exception Class" << std::endl;
 	 jenv -> ExceptionClear();
       }
       // Returned message could be null (unexpected)
       if (!jmsg) {
         std::cerr<< "Unexpected error: Class.getName returned null" << std::endl;
 	 return rslt;
       }

       rslt = GetStdString(jenv, jmsg);
       return rslt;
    }

    std::string GetStdString(JNIEnv *jenv, jstring jstr) {
      std::string rslt;
      if (!jenv) return rslt;  // assert, warn or something instead?
      if (jstr) {
        const char * utf_str = (const char *)jenv->GetStringUTFChars(jstr, NULL);	
        if (utf_str) {
 	  jint len = jenv->GetStringUTFLength(jstr); 
	  rslt.assign(utf_str, len);
	  jenv->ReleaseStringUTFChars(jstr,utf_str);
        }
      }
      return rslt;
    }

    bool ExceptionMatches(JNIEnv *jenv, jthrowable excp, const char * otherclassname) {
      if (!jenv) return false;  // unexpected, no jenv passed
      if (!excp) return false;  // No exception
      // consider caching method ids? Make static
      jclass classclz = jenv->FindClass("java/lang/Class");
      if (jenv->ExceptionCheck() || !classclz) {
        std::cerr<< "Unexpected error: Could not find class java/lang/Class" << std::endl;
	jenv -> ExceptionClear();
        return false;
      }

      jmethodID isClassInstanceMethodID = jenv->GetMethodID(classclz, "isInstance", "(Ljava/lang/Object;)Z");
      if (jenv->ExceptionCheck() || !isClassInstanceMethodID)  {
        std::cerr<< "Unexpected error: Could not find method isInstance on class java/lang/Class" << std::endl;
	jenv -> ExceptionClear();
        return false;
      }

      jclass other = jenv->FindClass(otherclassname);
      if (jenv->ExceptionCheck() || !other) {
        std::cerr<< "Error: Matching exception for " << otherclassname << ": class not found"  << std::endl;
	jenv -> ExceptionClear();
	return false;
      }

      jboolean matches = (jboolean)jenv->CallBooleanMethod(other, isClassInstanceMethodID, excp);
      if (jenv->ExceptionCheck()) {
        std::cerr<< "Error: error calling isInstance method" << std::endl;
	jenv -> ExceptionClear();
	return false;
      }
      return matches;
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

#endif /* __cplusplus */


