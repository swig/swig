// Test to check the exception classes in the throws attribute of the typemaps is working

%module java_throws

// Exceptions are chosen at random but are ones which have to have a try catch block to compile
%typemap(in, throws="	 ClassNotFoundException") int num { 
    $1 = (int)$input;
}
%typemap(freearg, throws="InstantiationException  ") int num "/*not written*/"
%typemap(argout, throws="CloneNotSupportedException		") int num "/*not written*/"
%typemap(check, throws="NoSuchFieldException") int num {
    if ($input == 10) {
        jenv->ExceptionClear();
        jclass excep = jenv->FindClass("java/lang/NoSuchFieldException");
        if (excep)
            jenv->ThrowNew(excep, "Value of 10 not acceptable");
    }
}

// Duplicate exceptions should be removed from the generated throws clause
%typemap(out, throws="IllegalAccessException, NoSuchFieldException,   CloneNotSupportedException    ") short { 
    $result = (jshort)$1; 
}

%inline %{
short full_of_exceptions(int num) {
    return 0;
}
%}


%typemap(throws, throws="IllegalAccessException") int {
    jclass excep = jenv->FindClass("java/lang/IllegalAccessException");
    if (excep)
        jenv->ThrowNew(excep, "Test exception");
    return $null;
}
%inline %{
void throw_spec_function(int value) throw (int) { throw (int)0; }
%}


// Check newfree typemap throws attribute
%newobject makeTestClass;
%typemap(newfree, throws="NoSuchMethodException") TestClass* "/*not written*/"
%inline %{
class TestClass {
    int x;
public:
    TestClass(int xx) : x(xx) {}
};
TestClass* makeTestClass() { return new TestClass(1000); }
%}


// javain typemap throws attribute
// Will only compile if the fileFunction has a java.io.IOException throws clause as getCanonicalPath() throws this exception
%typemap(jstype) char* someFileArgument "java.io.File"
%typemap(javain, throws="java.io.IOException") char* someFileArgument "$javainput.getCanonicalPath()"

%inline %{
void fileFunction(char* someFileArgument) {}
%}


// javout typemap throws attribute
%typemap(javaout, throws="java.io.IOException") int {
    int returnValue=$jnicall;
    if (returnValue==0) throw new java.io.IOException("some IOException");
    return returnValue;
  }

%inline %{
int ioTest() { return 0; }
%}
