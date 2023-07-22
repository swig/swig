%module template_templated_constructors

%inline %{
namespace ConstructSpace {

class TConstructor1 {
public:
  template<typename T> TConstructor1(T val) {}
  ~TConstructor1() {}
};

class TConstructor2 {
public:
  TConstructor2() {}
  template<typename T> TConstructor2(T val) {}
  ~TConstructor2() {}
};

class TConstructor3 {
public:
  // No implicit default constructor available
  template<typename T> TConstructor3(T val) {}
  ~TConstructor3() {}
};

class TConstructor4 {
public:
  // No constructors available from wrappers when there is no %template to instantiate templated constructor
  template<typename T> TConstructor4() {}
  ~TConstructor4() {}
};

template<typename T> class TClass1 {
public:
  template<typename Y> TClass1(Y t) {}
};

template<typename T> class TClass2 {
public:
  TClass2() {}
  template<typename Y> TClass2(Y t) {}
};

}
%}

%extend ConstructSpace::TConstructor1 {
  %template(TConstructor1) TConstructor1<int>;
}

%template(TConstructor2) ConstructSpace::TConstructor2::TConstructor2<int>;

%template(TClass1Int) ConstructSpace::TClass1<int>;
%extend ConstructSpace::TClass1<int> {
  %template(TClass1Int) TClass1<double>;
}

%template(TClass2Int) ConstructSpace::TClass2<int>;
%extend ConstructSpace::TClass2<int> {
  %template(TClass2Int) TClass2<double>;
}

%inline %{
// Simple version of std::pair
namespace Standard {
  template <class T, class U > struct Pair {
    typedef T first_type;
    typedef U second_type;
    Pair() {}
    Pair(const T& first, const U& second) {}
    Pair(const Pair& other) {}

    template <class U1, class U2> Pair(const Pair< U1, U2 > &otherone) {}
  };
}
%}

%include <std_string.i>

namespace Standard {
  %template(StringPair) Pair<std::string, std::string>;
  %template(ShortPair) Pair<short, short>;
  %template(IntPair) Pair<int, int>;
  %template(DoublePair) Pair<double, double>;
  %extend Pair<int, int> {
    // Templated constructor which uses 'correct' name of the containing class (IntPair)
    %template(IntPair) Pair<short, short>;
    // Templated constructors that behave differently in different languages as the template name
    // does not match IntPair, the instantiated name for Pair<int, int>.
    // Some languages wrap as a factory style function (Python), 
    // others ignore the name and wrap as regular constructor (Java).
    %template(Pair) Pair<double, double>;
    %template(MakeStringPair) Pair<std::string, std::string>;
  }
}
