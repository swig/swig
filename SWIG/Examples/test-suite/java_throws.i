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

