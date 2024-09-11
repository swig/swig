%module c_backend_cpp_exception

%exception {
  try {
    $action
  } catch(SomeKnownException) {
    checkVal = 1;
  } catch(...) {
    checkVal = 2;
  }
}

%inline %{
  class SomeKnownException{};
  class SomeUnkownException{};
  int checkVal = 0;

  void throwSomeKnownException(void) {
    throw SomeKnownException();
  }

  void throwSomeUnknownException(void) {
    throw SomeUnkownException();
  }
%}
