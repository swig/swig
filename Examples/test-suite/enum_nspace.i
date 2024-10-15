%module enum_nspace

%nspace;

%inline %{

namespace outer {
  namespace inner {
    typedef enum _choice {
      NO = 0,
      YES
    } Choice;
  }
  bool select3(inner::Choice arg) {
    return arg == inner::YES;
  }
  typedef inner::Choice YetAnotherName;
}

bool select1(enum outer::inner::_choice arg) {
  return arg == outer::inner::YES;
}

bool select2(outer::inner::Choice arg) {
  return arg == outer::inner::YES;
}

bool select4(outer::YetAnotherName arg) {
  return arg == outer::inner::YES;
}
%}
