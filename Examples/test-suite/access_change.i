%module access_change

// test access changing from protected to public

%inline %{

template<typename T> class Base {
public:
  virtual ~Base() {}
protected:
  virtual int * WasProtected1() { return 0; }
  int * WasProtected2() { return 0; }
  virtual int * WasProtected3() { return 0; }
  int * WasProtected4() { return 0; }
};

template<typename T> class Derived : public Base<T> {
public:
  int * WasProtected1() { return 0; }
  int * WasProtected2() { return 0; }
  using Base<T>::WasProtected3;
  using Base<T>::WasProtected4;
};

template<typename T> class Bottom : public Derived<T> {
public:
  int * WasProtected1() { return 0; }
  int * WasProtected2() { return 0; }
  using Base<T>::WasProtected3;
  using Base<T>::WasProtected4;
};
%}

%template(BaseInt) Base<int>;
%template(DerivedInt) Derived<int>;
%template(BottomInt) Bottom<int>;


