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
public:
  Base() : m(-1) {}
  Base(int i) : m(i) {}
  int get_m() { return m; }
  int m;
};

class Derived : public Base {
public:
  Derived() : n(-2) {}
  Derived(int i) : n(i) {}
  int get_n() { return n; }
  int n;
};

 typedef std::shared_ptr<Base>    BasePtr;
 typedef std::shared_ptr<Derived> DerivedPtr;

 int derived_num(DerivedPtr v) {
   return (*v).get_n();
 }

 int derived_num(std::vector<DerivedPtr> v) {
   return (*v[0]).get_n();
 }

 int derived_num(std::map<int, DerivedPtr> v) {
   return (*v[0]).get_n();
 }

 int base_num(BasePtr v) {
   return (*v).get_m();
 }

 int base_num(std::vector<BasePtr > v) {
   return (*v[0]).get_m();
 }

 int base_num(std::map<int, BasePtr > v) {
   return (*v[0]).get_m();
 }

%}


%shared_ptr(Base);
%shared_ptr(Derived);

%template(BaseList) std::vector<std::shared_ptr<Base> >;
%template(DerivedList) std::vector<std::shared_ptr<Derived> >;

%template(BaseMap) std::map<int, std::shared_ptr<Base> >;
%template(DerivedMap) std::map<int, std::shared_ptr<Derived> >;

class Base {
public:
  Base();
  int get_m();
  int m;
};

class Derived : public Base {
public:
  Derived();
  Derived(int i);
  int get_n();
  int n;
};

typedef std::shared_ptr<Base>    BasePtr;
typedef std::shared_ptr<Derived> DerivedPtr;

int derived_num(DerivedPtr);
int derived_num(std::vector<std::shared_ptr<Derived> > v);
int derived_num(std::map<int, DerivedPtr> v);
int base_num(BasePtr);
int base_num(std::vector<std::shared_ptr<Base> > v);
int base_num(std::map<int, BasePtr > v);

