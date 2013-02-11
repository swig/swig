/* -----------------------------------------------------------------------------
 * director_except_utils.swg
 *
 * This file contains support utilities to map Java thrown
 * exceptions to c++ exceptions for use with the director:except feature.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include <string>
//#include <iostream>  

namespace Swig {
    // These functions are always called in the context of an active JNIenv in director
    //   method dispatch.  These are utilities to simplify converting Java Exceptions 
    //   into C++ exceptions

    std::string get_std_string(JNIEnv *jenv, jstring jstr) {
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

    std::string get_exception_message(JNIEnv *jenv, jthrowable excp) {
       std::string rslt;
       if (!jenv || !excp) return rslt;  // no exception or unexpected call parameters
       
       jclass thrwclz = jenv->GetObjectClass(excp);
       if (jenv->ExceptionCheck() || !thrwclz) {
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jmethodID getThrowableMessageMethodID = jenv->GetMethodID(thrwclz, "getMessage", "()Ljava/lang/String;");
       if (jenv->ExceptionCheck() || !getThrowableMessageMethodID) {
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jstring jmsg = (jstring)jenv->CallObjectMethod(excp, getThrowableMessageMethodID);
       if (jenv->ExceptionCheck()) {
 	 jenv -> ExceptionClear();
       }
       // Returned message could be null (unexpected)
       if (!jmsg) {
 	 return rslt;
       }

       //TODO: handle better for non-ascii?  Need encoding and wchar std::wstring ...
       rslt = get_std_string(jenv, jmsg);
       return rslt;
    }

    // Can be used to report improper exception translation.  Not used automatically by generated code.
    std::string get_class_name(JNIEnv *jenv, jthrowable excp) {
       std::string rslt;
       if (!jenv || !excp) return rslt;  // no exception or unexpected call parameters
       
       jclass thrwclz = jenv->GetObjectClass(excp);
       jclass classclz = jenv->FindClass("java/lang/Class");

       jmethodID getNameMethodID = jenv->GetMethodID(classclz, "getName", "()Ljava/lang/String;");
       if (jenv->ExceptionCheck() || !getNameMethodID) {
 	 jenv -> ExceptionClear();
 	 return rslt;
       }

       jstring jmsg = (jstring)jenv->CallObjectMethod(thrwclz, getNameMethodID);
       if (jenv->ExceptionCheck()) {
 	 jenv -> ExceptionClear();
       }
       // Returned message could be null (unexpected)
       if (!jmsg) {
 	 return rslt;
       }

       rslt = get_std_string(jenv, jmsg);
       return rslt;
    }

    bool exception_matches(JNIEnv *jenv, jthrowable excp, const char * otherclassname) {
      if (!jenv) return false;  // unexpected, no jenv passed
      if (!excp) return false;  // No exception
      // consider caching method ids? Make static
      jclass classclz = jenv->FindClass("java/lang/Class");
      if (jenv->ExceptionCheck() || !classclz) {
	jenv -> ExceptionClear();
        return false;
      }

      jmethodID isClassInstanceMethodID = jenv->GetMethodID(classclz, "isInstance", "(Ljava/lang/Object;)Z");
      if (jenv->ExceptionCheck() || !isClassInstanceMethodID)  {
	jenv -> ExceptionClear();
        return false;
      }

      jclass other = jenv->FindClass(otherclassname);
      if (jenv->ExceptionCheck() || !other) {
        //If the matches classname not found, always false. Uncomment to debug class not found issues.
        //std::cerr<< "Error: Matching exception for " << otherclassname << ": class not found"  << std::endl;
	jenv -> ExceptionClear();
	return false;
      }

      jboolean matches = (jboolean)jenv->CallBooleanMethod(other, isClassInstanceMethodID, excp);
      if (jenv->ExceptionCheck()) {
	jenv -> ExceptionClear();
	return false;
      }
      return matches;
    }
}

#endif /* __cplusplus */


