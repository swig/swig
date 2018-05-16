%module cpp11_shared_ptr_upcast

%{
#include <set>
#include <map>
#include <memory>
#include <unordered_set>
#include <unordered_map>
#include <vector>
%}

%include <std_vector.i>
%include <std_map.i>
%include <std_shared_ptr.i>

%{

class Base {
  int m;
public:
  Base() : m(-1) {}
  Base(int i) : m(i) {}
  int get_m() { return m; }
};

class Derived : public Base {
  int n;
public:
  Derived() : n(-2) {}
  Derived(int i) : n(i) {}
  int get_n() { return n; }
};

typedef std::shared_ptr<Base>    BasePtr;
typedef std::shared_ptr<Derived> DerivedPtr;

// non-overloaded
int derived_num1(DerivedPtr v) {
 return v == nullptr ? 999 : (*v).get_n();
}

int derived_num2(std::vector<DerivedPtr> v) {
 return v[0] == nullptr ? 999 : (*v[0]).get_n();
}

int derived_num3(std::map<int, DerivedPtr> v) {
 return v[0] == nullptr ? 999 : (*v[0]).get_n();
}

int base_num1(BasePtr v) {
 return v == nullptr ? 999 : (*v).get_m();
}

int base_num2(std::vector<BasePtr > v) {
 return v[0] == nullptr ? 999 : (*v[0]).get_m();
}

int base_num3(std::map<int, BasePtr > v) {
 return v[0] == nullptr ? 999 : (*v[0]).get_m();
}

// overloaded
int derived_num(DerivedPtr v) {
 return derived_num1(v);
}

int derived_num(std::vector<DerivedPtr> v) {
 return derived_num2(v);
}

int derived_num(std::map<int, DerivedPtr> v) {
 return derived_num3(v);
}

int base_num(BasePtr v) {
 return base_num1(v);
}

int base_num(std::vector<BasePtr > v) {
 return base_num2(v);
}

int base_num(std::map<int, BasePtr > v) {
 return base_num3(v);
}
%}


%shared_ptr(Base);
%shared_ptr(Derived);

%template(BaseList) std::vector<std::shared_ptr<Base> >;
%template(DerivedList) std::vector<std::shared_ptr<Derived> >;

%template(BaseMap) std::map<int, std::shared_ptr<Base> >;
%template(DerivedMap) std::map<int, std::shared_ptr<Derived> >;

class Base {
  int m;
public:
  Base();
  int get_m();
};

class Derived : public Base {
  int n;
public:
  Derived();
  Derived(int i);
  int get_n();
};

typedef std::shared_ptr<Base>    BasePtr;
typedef std::shared_ptr<Derived> DerivedPtr;

// non-overloaded
int derived_num1(DerivedPtr);
int derived_num2(std::vector<std::shared_ptr<Derived> > v);
int derived_num3(std::map<int, DerivedPtr> v);
int base_num1(BasePtr);
int base_num2(std::vector<std::shared_ptr<Base> > v);
int base_num3(std::map<int, BasePtr > v);

// overloaded
int derived_num(DerivedPtr);
int derived_num(std::vector<std::shared_ptr<Derived> > v);
int derived_num(std::map<int, DerivedPtr> v);
int base_num(BasePtr);
int base_num(std::vector<std::shared_ptr<Base> > v);
int base_num(std::map<int, BasePtr > v);

// ptr to shared_ptr
%shared_ptr(Base2);
%shared_ptr(Derived2)

%inline %{
class Base2 {
  int m;
public:
  Base2() : m(-1) {}
  Base2(int i) : m(i) {}
  int get_m() { return m; }
};


class Derived2 : public Base2 {
  int n;
public:
  Derived2() : n(0) {}
  Derived2(int i) : n(i) {}
  int get_n_2() { return n; }
};
%}

%template(Base2List) std::vector<std::shared_ptr<Base2> * >;
%template(Base2Map) std::map<int, std::shared_ptr<Base2> * >;

%template(Derived2List) std::vector<std::shared_ptr<Derived2> * >;
%template(Derived2Map) std::map<int, std::shared_ptr<Derived2> * >;

%inline %{
typedef std::shared_ptr<Derived2> * Derived2Ptr;
typedef std::shared_ptr<Base2> * Base2Ptr;

int base2_num1(Base2Ptr v) {
  return v == nullptr ? 999 : *v == nullptr ? 888 : (*v)->get_m();
}

int base2_num2(std::vector<Base2Ptr> v) {
  return v[0] == nullptr ? 999 : *v[0] == nullptr ? 888 : (*v[0])->get_m();
}

int base2_num3(std::map<int, Base2Ptr> v) {
  return v[0] == nullptr ? 999 : *v[0] == nullptr ? 888 : (*v[0])->get_m();
}

int derived2_num1(Derived2Ptr v) {
  return v == nullptr ? 999 : *v == nullptr ? 888 : (*v)->get_n_2();
}

int derived2_num2(std::vector<Derived2Ptr> v) {
  return v[0] == nullptr ? 999 : *v[0] == nullptr ? 888 : (*v[0])->get_n_2();
}

int derived2_num3(std::map<int, Derived2Ptr> v) {
  return v[0] == nullptr ? 999 : *v[0] == nullptr ? 888 : (*v[0])->get_n_2();
}
%}
