%module(directors="1") java_director_exception_feature

%include <std_except.i>

%{

#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif

#include <string>


// define dummy director exception classes to prevent spurious errors 
// in target languages that do not support directors.

#ifndef SWIG_DIRECTORS
namespace Swig {
class DirectorException {};
class DirectorMethodException: public Swig::DirectorException {};
}
  #ifndef SWIG_fail
    #define SWIG_fail
  #endif
#endif /* !SWIG_DIRECTORS */


%}

%include "std_string.i"

#ifdef SWIGJAVA

%include <std_string.i>

// DEFINE exceptions in header section using std::runtime_error
%{
  #include <exception>
  struct Exception1 : public std::runtime_error {
    Exception1(const std::string& what):runtime_error(what) {}
  };
  struct Exception2 : public std::runtime_error {
    Exception2(const std::string& what):runtime_error(what) {}
  };
  struct Unexpected : public std::runtime_error {
    Unexpected(const std::string& what):runtime_error(what) {}
  };

%}

// Add an explicit handler for one method, mapping one java exception back to an 'int' 
%feature("director:except",fullname=1) Foo::ping {
  if (Swig::exception_matches(jenv,$thrown,"$packagepath/MyJavaException1")) {
    throw 1;
  } 
  else if (Swig::exception_matches(jenv,$thrown,"$packagepath/MyJavaException2")) {
    std::string msg = Swig::get_exception_message(jenv,$thrown);
    throw ::Exception2(msg);
  }
}

// Add a handler using directorthrows typemaps (no code block on feature)
%feature("director:except",fullname=1) Foo::pong;

// directorthrows typemaps for java->c++ conversions
%typemap(directorthrows,matches="$packagepath/MyJavaException1") Exception1 {
  std::string msg = Swig::get_exception_message(jenv,$thrown);
  throw ::Exception1(msg);
}

%typemap(directorthrows,matches="$packagepath/MyJavaException2") Exception2 {
  std::string msg = Swig::get_exception_message(jenv,$thrown);
  throw ::Exception2(msg);
}

// Make this catch-all for any exception including unchecked
%typemap(directorthrows,matches="java.lang.Throwable") Unexpected {
  std::string msg = Swig::get_exception_message(jenv,$thrown);
  throw ::Unexpected(msg);
}

// TODO 'throws' typemap emitted by emit_action has no way to get access 
// to language specific special variables like $packagepath
// throws typemaps for c++->java exception conversions
%typemap(throws,throws="MyJavaException1") Exception1 {
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException1");  // How to get real exception name $javaclassname, $package
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
   }
  return $null;
}

%typemap(throws,throws="MyJavaException1") int {
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException1"); // How to get real exception name $javaclassname, $package
  if (excpcls) {
    jenv->ThrowNew(excpcls, "Threw some integer");
  }
  return $null;
}

%typemap(throws,throws="MyJavaException2") Exception2 {
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException2"); // How to get real exception name $javaclassname, $package
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
  }
  return $null;
}

%typemap(throws,throws="MyJavaUnexpected") Unexpected {
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaUnexpected"); // How to get real exception name $javaclassname, $package
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
  }
  return $null;
}

#endif

%feature("director") Foo;

// Rename exceptions on java side for clarity 
%rename(MyJavaException1) Exception1;
%rename(MyJavaException2) Exception2;
%rename(MyJavaUnexpected) Unexpected;

%typemap(javabase) Exception1,Exception2,Unexpected "java.lang.Exception";
%rename(getMessage) what();  // Rename all what() methods

struct Exception1 {
    Exception1(const std::string& what);
    const char * what();
};
struct Exception2 {
    Exception2(const std::string& what);
    const char * what();
};
struct Unexpected {
    Unexpected(const std::string& what);
    const char * what();
};

%inline %{

class Foo {
public:
  virtual ~Foo() {}
  // ping java implementation throws a java Exception1 or an Exception2 if excp is 1 or 2.
  // pong java implementation throws Exception1,Exception2,Unexpected,NullPointerException for 1,2,3,4
  virtual std::string ping(int excp) throw(int,Exception2) = 0; 
  virtual std::string pong(int excp) throw(Exception1, Exception2, Unexpected) = 0; 
};

// Make a bar from a foo, so a call to Java Bar
// goes Java Bar -> C++ Bar -> C++ Foo -> Java Foo Director
class Bar {
public:
  Bar(Foo* d) { delegate=d; }
  virtual std::string ping(int excp) throw(int,Exception2)
  { 
    return delegate->ping(excp); 
  }

  virtual std::string pong(int excp) throw(Exception1, Exception2, Unexpected)
  { 
    return delegate->pong(excp);
  }
    
private:
  Foo * delegate;
};

 %}
