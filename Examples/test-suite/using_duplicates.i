%module using_duplicates

%inline %{
namespace aa {
  struct UsedFromNS {
    int value;
  };
}

template<typename T> class Container {
public:
  T item;
  T get() const { return item; }
  void set(T t) { item = t; }
};
%}

using aa::UsedFromNS;
using aa::UsedFromNS; // Duplicate using declaration (the regression being tested)

%template(ContainerUsedFromNS) Container< UsedFromNS >;
