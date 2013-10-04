%module(directors="1") java_director_exception_feature

%include <std_except.i>

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif

#include <string>
%}

%include <std_string.i>

// DEFINE exceptions in header section using std::runtime_error
%{
  #include <exception>
  #include <iostream>

  namespace MyNS {

    struct Exception1 : public std::runtime_error {
      Exception1(const std::string& what):runtime_error(what) {}
    };
    struct Exception2 : public std::runtime_error {
      Exception2(const std::string& what):runtime_error(what) {}
    };
    struct Unexpected : public std::runtime_error {
      Unexpected(const std::string& what):runtime_error(what) {}
    };

  }

%}

// Add an explicit handler for Foo::ping, mapping one java exception back to an 'int' 
%feature("director:except") Foo::ping {
  jthrowable $error = jenv->ExceptionOccurred();
  if ($error) {
    //jenv->ExceptionClear();  // clear java exeption since mapping into a c++ exception
    if (Swig::ExceptionMatches(jenv,$error,"$packagepath/MyJavaException1")) {
      throw 1;
    } else if (Swig::ExceptionMatches(jenv,$error,"$packagepath/MyJavaException2")) {
      std::string msg(Swig::JavaExceptionMessage(jenv,$error).message());
      throw MyNS::Exception2(msg);
    } else {
      std::cerr << "Test failed, unexpected exception thrown: " << Swig::JavaExceptionMessage(jenv,$error).message();
      throw std::runtime_error("unexpected exception in Foo::ping");
    }
  }
}

// Use default handler on Foo::pong, with directorthrows typemaps

// directorthrows typemaps for java->c++ conversions
%typemap(directorthrows,matches="$packagepath/MyJavaException1") MyNS::Exception1 %{
  std::string msg(Swig::JavaExceptionMessage(jenv,$error).message());
  throw ::MyNS::Exception1(msg);
%}

%typemap(directorthrows,matches="$packagepath/MyJavaException2") MyNS::Exception2 %{
  std::string msg(Swig::JavaExceptionMessage(jenv,$error).message());
  throw ::MyNS::Exception2(msg);
%}

%typemap(directorthrows,matches="$packagepath/MyJavaUnexpected") MyNS::Unexpected %{
  std::string msg(Swig::JavaExceptionMessage(jenv,$error).message());
  throw ::MyNS::Unexpected(msg);
%}

// Override the director:except defaulthandler attribute for a particular method
%feature("director:except:defaulthandler") Foo::pong %{
  throw ::MyNS::Unexpected(Swig::JavaExceptionMessage(jenv,$error).message());
%}

// TODO 'throws' typemap emitted by emit_action has no way to get access 
// to language specific special variables like $packagepath ("java_director_exception_feature" here)

// throws typemaps for c++->java exception conversions
%typemap(throws,throws="MyJavaException1") MyNS::Exception1 %{
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException1");  
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
   }
  return $null;
%}

%typemap(throws,throws="MyJavaException1") int %{
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException1"); 
  if (excpcls) {
    jenv->ThrowNew(excpcls, "Threw some integer");
  }
  return $null;
%}

%typemap(throws,throws="MyJavaException2") MyNS::Exception2 %{
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaException2"); 
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
  }
  return $null;
%}

%typemap(throws,throws="MyJavaUnexpected") MyNS::Unexpected %{
  jclass excpcls = jenv->FindClass("java_director_exception_feature/MyJavaUnexpected"); 
  if (excpcls) {
    jenv->ThrowNew(excpcls, $1.what());
  }
  return $null;
%}

%feature("director") Foo;

// Rename exceptions on java side to make translation of exceptions more clear
%rename(MyJavaException1,fullname=1) MyNS::Exception1;
%rename(MyJavaException2,fullname=1) MyNS::Exception2;
%rename(MyJavaUnexpected,fullname=1) MyNS::Unexpected;

%typemap(javabase) ::MyNS::Exception1,::MyNS::Exception2,::MyNS::Unexpected "java.lang.Exception";
%rename(getMessage) what();  // Rename all what() methods

namespace MyNS {

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

}
// In general it is better to use %catches instead of an exception specification on the method
//   since violating an exception specification calls terminate() preventing catch-all behavior
//   like throwing std::runtime_error.  But an exception specification must be used if the
//   actual interface being wrapped does use them.
%catches(MyNS::Exception1,MyNS::Exception2,MyNS::Unexpected) Foo::pong;
%catches(MyNS::Exception1,MyNS::Exception2,MyNS::Unexpected) Bar::pong;

%inline %{

class Foo {
public:
  virtual ~Foo() {}
  // ping java implementation throws a java Exception1 or an Exception2 if excp is 1 or 2.
  // pong java implementation throws Exception1,Exception2,Unexpected,NullPointerException for 1,2,3,4
  virtual std::string ping(int excp) throw(int,MyNS::Exception2) = 0; 
  virtual std::string pong(int excp) /* throws MyNS::Exception1 MyNS::Exception2 MyNS::Unexpected) */ = 0; 
};

// Make a bar from a foo, so a call to Java Bar
// goes Java Bar -> C++ Bar -> C++ Foo -> Java Foo Director

class Bar {
public:
  Bar(Foo* d) { delegate=d; }
  virtual std::string ping(int excp) throw(int,MyNS::Exception2)
  { 
    return delegate->ping(excp); 
  }

  virtual std::string pong(int excp) /* throws MyNS::Exception1,MyNS::Exception2,MyNS::Unexpected */
  { 
    return delegate->pong(excp);
  }
    
private:
  Foo * delegate;
};

%}
