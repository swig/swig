// TODO: STL exception handling
// Note that the generic std_except.i file did not work

namespace std {
  %ignore exception;
  struct exception {
  };
}

