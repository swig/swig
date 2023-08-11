%module cpp11_using_constructor

// Note: this testcase is also used by cpp11_director_using_constructor.i

%inline %{
// Public base constructors
struct PublicBase1 {
  virtual ~PublicBase1() {}
  PublicBase1(int i, const char* s) {}
  virtual void meth() {}
};
struct PublicDerived1 : PublicBase1 {
  using PublicBase1::PublicBase1;
  using PublicBase1::meth;
};

struct PublicBase2 {
  virtual ~PublicBase2() {}
  PublicBase2(int i, const char* s) {}
  PublicBase2() {}
  virtual void meth() {}
};
struct PublicDerived2 : PublicBase2 {
  using PublicBase2::PublicBase2;
  using PublicBase2::meth;
};

struct PublicBase3 {
  virtual ~PublicBase3() {}
  PublicBase3(int i, const char* s) {}
  PublicBase3() = default;
  virtual void meth() {}
};
struct PublicDerived3 : PublicBase3 {
  using PublicBase3::PublicBase3;
  using PublicBase3::meth;
};

struct PublicBase4 {
  virtual ~PublicBase4() {}
  PublicBase4() = default;
  virtual void meth() {}
};
struct PublicDerived4 : PublicBase4 {
  using PublicBase4::PublicBase4;
  using PublicBase4::meth;
};

struct PublicBase5 {
  virtual ~PublicBase5() {}
  // implicit constructor
  virtual void meth() {}
};
struct PublicDerived5 : PublicBase5 {
  using PublicBase5::PublicBase5;
  using PublicBase5::meth;
};

// Protected base constructors
struct ProtectedBase1 {
  virtual ~ProtectedBase1() {}
protected:
  ProtectedBase1(int i, const char* s) {}
  virtual void meth() {}
};
struct ProtectedDerived1 : ProtectedBase1 {
  using ProtectedBase1::ProtectedBase1;
  using ProtectedBase1::meth;
};

struct ProtectedBase2 {
  virtual ~ProtectedBase2() {}
protected:
  ProtectedBase2(int i, const char* s) {}
  ProtectedBase2() {}
  virtual void meth() {}
};
struct ProtectedDerived2 : ProtectedBase2 {
  using ProtectedBase2::ProtectedBase2;
  using ProtectedBase2::meth;
};

struct ProtectedBase3 {
  virtual ~ProtectedBase3() {}
protected:
  ProtectedBase3(int i, const char* s) {}
  ProtectedBase3() = default;
  virtual void meth() {}
};
struct ProtectedDerived3 : ProtectedBase3 {
  using ProtectedBase3::ProtectedBase3;
  using ProtectedBase3::meth;
};

struct ProtectedBase4 {
  virtual ~ProtectedBase4() {}
protected:
  ProtectedBase4() = default;
  virtual void meth() {}
};
struct ProtectedDerived4 : ProtectedBase4 {
  using ProtectedBase4::ProtectedBase4;
  using ProtectedBase4::meth;
};

struct ProtectedBase5 {
  virtual ~ProtectedBase5() {}
  // implicit constructor
protected:
  virtual void meth() {}
};
struct ProtectedDerived5 : ProtectedBase5 {
  using ProtectedBase5::ProtectedBase5;
  using ProtectedBase5::meth;
};

// Mix of public and overloaded constructors
struct MixedBase1 {
  virtual ~MixedBase1() {}
  MixedBase1(int i, const char* s) {}
  virtual void meth() {}
};
struct MixedDerived1a : MixedBase1 {
  MixedDerived1a() : MixedBase1(0, 0) {}
  using MixedBase1::MixedBase1;
  using MixedBase1::meth;
};
struct MixedDerived1b : MixedBase1 {
  using MixedBase1::MixedBase1;
  MixedDerived1b() : MixedBase1(0, 0) {}
  using MixedBase1::meth;
};

struct MixedBase2 {
  virtual ~MixedBase2() {}
  MixedBase2(int i, const char* s) {}
  MixedBase2() {}
  virtual void meth() {}
};
struct MixedDerived2a : MixedBase2 {
  MixedDerived2a(int i, const char* s) {}
  using MixedBase2::MixedBase2;
  using MixedBase2::meth;
};
struct MixedDerived2b : MixedBase2 {
  using MixedBase2::MixedBase2;
  MixedDerived2b(int i, const char* s) {}
  using MixedBase2::meth;
};
struct MixedDerived2c : MixedBase2 {
  using MixedBase2::MixedBase2;
  MixedDerived2c(int ii) : MixedBase2(ii, 0) {}
  using MixedBase2::meth;
};
struct MixedDerived2d : MixedBase2 {
  MixedDerived2d(int ii) : MixedBase2(ii, 0) {}
  using MixedBase2::MixedBase2;
  using MixedBase2::meth;
};

struct MixedBase3 {
  virtual ~MixedBase3() {}
  MixedBase3(int i, const char* s) {}
  MixedBase3() = default;
  virtual void meth() {}
};
struct MixedDerived3a : MixedBase3 {
  MixedDerived3a(int i, const char* s) {}
  using MixedBase3::MixedBase3;
  using MixedBase3::meth;
};
struct MixedDerived3b : MixedBase3 {
  using MixedBase3::MixedBase3;
  MixedDerived3b(int i, const char* s) {}
  using MixedBase3::meth;
};
struct MixedDerived3c : MixedBase3 {
  using MixedBase3::MixedBase3;
  MixedDerived3c(int ii) : MixedBase3(ii, 0) {}
  using MixedBase3::meth;
};
struct MixedDerived3d : MixedBase3 {
  MixedDerived3d(int ii) : MixedBase3(ii, 0) {}
  using MixedBase3::MixedBase3;
  using MixedBase3::meth;
};

struct MixedBase4 {
  virtual ~MixedBase4() {}
  virtual void meth() {}
};
struct MixedDerived4a : MixedBase4 {
  MixedDerived4a(int i, const char* s) {}
  using MixedBase4::MixedBase4;
  using MixedBase4::meth;
};
struct MixedDerived4b : MixedBase4 {
  using MixedBase4::MixedBase4;
  MixedDerived4b(int i, const char* s) {}
  using MixedBase4::meth;
};
struct MixedDerived4c : MixedBase4 {
  using MixedBase4::MixedBase4;
  MixedDerived4c(int ii) {}
  using MixedBase4::meth;
};
struct MixedDerived4d : MixedBase4 {
  MixedDerived4d(int ii) {}
  using MixedBase4::MixedBase4;
  using MixedBase4::meth;
};
struct MixedDerived4e : MixedBase4 {
  MixedDerived4e() {}
  using MixedBase4::MixedBase4;
  using MixedBase4::meth;
};
struct MixedDerived4f : MixedBase4 {
  using MixedBase4::MixedBase4;
  MixedDerived4f() {}
  using MixedBase4::meth;
};

// Mix of protected base constructors and overloading
struct ProotBase1 {
  virtual ~ProotBase1() {}
  ProotBase1() {}
protected:
  ProotBase1(int i, const char* s) {}
  virtual void meth() {}
};
struct ProotDerived1a : ProotBase1 {
  using ProotBase1::ProotBase1;
  using ProotBase1::meth;
};
struct ProotDerived1b : ProotBase1 {
  using ProotBase1::ProotBase1;
  ProotDerived1b(int i, const char* s) : ProotBase1(i, s) {}
  using ProotBase1::meth;
};
struct ProotDerived1c : ProotBase1 {
  ProotDerived1c(int i, const char* s) : ProotBase1(i, s) {}
  using ProotBase1::ProotBase1;
  using ProotBase1::meth;
};
struct ProotDerived1d : ProotBase1 {
  using ProotBase1::ProotBase1;
  ProotDerived1d(int ii) : ProotBase1(ii, 0) {}
  using ProotBase1::meth;
};
struct ProotDerived1e : ProotBase1 {
  ProotDerived1e(int ii) : ProotBase1(ii, 0) {}
  using ProotBase1::ProotBase1;
  using ProotBase1::meth;
};

struct ProotBase2 {
  virtual ~ProotBase2() {}
protected:
  ProotBase2(int i, const char* s) {}
  ProotBase2() {}
  virtual void meth() {}
};
struct ProotDerived2a : ProotBase2 {
  ProotDerived2a(int i, const char* s) {}
  using ProotBase2::ProotBase2;
  using ProotBase2::meth;
};
struct ProotDerived2b : ProotBase2 {
  using ProotBase2::ProotBase2;
  ProotDerived2b(int i, const char* s) {}
  using ProotBase2::meth;
};
struct ProotDerived2c : ProotBase2 {
  ProotDerived2c(int i, const char* s) {}
  ProotDerived2c() {}
  using ProotBase2::ProotBase2;
  using ProotBase2::meth;
};
struct ProotDerived2d : ProotBase2 {
  ProotDerived2d(int i, const char* s) {}
  using ProotBase2::ProotBase2;
  ProotDerived2d() {}
  using ProotBase2::meth;
};
struct ProotDerived2e : ProotBase2 {
  using ProotBase2::ProotBase2;
  ProotDerived2e(int i, const char* s) {}
  ProotDerived2e() {}
  using ProotBase2::meth;
};
struct ProotDerived2f : ProotBase2 {
  using ProotBase2::ProotBase2;
  ProotDerived2f(int i, const char* s) {}
  ProotDerived2f() {}
  ProotDerived2f(int) {}
  using ProotBase2::meth;
};

// Deeper inheritance chain
struct DeepBase1 {
  virtual ~DeepBase1() {}
  DeepBase1(int i) {}
};
struct DeepBase2 : DeepBase1 {
  DeepBase2(int i, int j) : DeepBase1(i+j) {}
  using DeepBase1::DeepBase1;
};
struct DeepBase3 : DeepBase2 {
  DeepBase3(int i, int j, int k) : DeepBase2(i+j+k) {}
  using DeepBase2::DeepBase2;
};

struct DeepProtectedBase1 {
  virtual ~DeepProtectedBase1() {}
protected:
  DeepProtectedBase1(int i) {}
};
struct DeepProtectedBase2 : DeepProtectedBase1 {
protected:
  DeepProtectedBase2(int i, int j) : DeepProtectedBase1(i+j) {}
  using DeepProtectedBase1::DeepProtectedBase1;
};
struct DeepProtectedBase3 : DeepProtectedBase2 {
  DeepProtectedBase3(int i, int j, int k) : DeepProtectedBase2(i+j+k) {}
  using DeepProtectedBase2::DeepProtectedBase2;
};

void cpptester() {
    DeepBase3 db3 = DeepBase3(11);
    db3 = DeepBase3(11, 22);
    db3 = DeepBase3(11, 22, 33);
    DeepProtectedBase3 dbp3 = DeepProtectedBase3(11, 22, 33);
}

%}

// Missing base
%warnfilter(SWIGWARN_TYPE_UNDEFINED_CLASS, SWIGWARN_PARSE_USING_UNDEF) HiddenDerived1;
%{
struct HiddenBase1 {
  virtual ~HiddenBase1() {}
  HiddenBase1(int i, const char* s) {}
  HiddenBase1() {}
  virtual void meth() {}
};
%}
%inline %{
struct HiddenDerived1 : HiddenBase1 {
  using HiddenBase1::HiddenBase1;
  using HiddenBase1::meth;
};
%}

#if 0 // not yet working
// Typedefs and using declarations
%inline %{
struct TypedefBase1 {
  TypedefBase1(int i, const char* s) {}
  virtual void meth() {}
};
struct TypedefDerived1 : TypedefBase1 {
  typedef TypedefBase1 Superclass;
  using Superclass::TypedefBase1;
};
void tester() {
    TypedefDerived1 td(0, "hi");
    td.meth();
}
%}
#endif

%inline %{
// Templates and public base constructors (derive from non-template)
template<typename T>
struct TemplatePublicDerived1 : PublicBase1 {
  using PublicBase1::PublicBase1;
  using PublicBase1::meth;
};

template<typename T>
struct TemplatePublicDerived2 : PublicBase2 {
  using PublicBase2::PublicBase2;
  using PublicBase2::meth;
};

template<typename T>
struct TemplatePublicDerived3 : PublicBase3 {
  using PublicBase3::PublicBase3;
  using PublicBase3::meth;
};

template<typename T>
struct TemplatePublicDerived4 : PublicBase4 {
  using PublicBase4::PublicBase4;
  using PublicBase4::meth;
};

template<typename T>
struct TemplatePublicDerived5 : PublicBase5 {
  using PublicBase5::PublicBase5;
  using PublicBase5::meth;
};
%}
%template(TemplatePublicDerived1Int) TemplatePublicDerived1<int>;
%template(TemplatePublicDerived2Int) TemplatePublicDerived2<int>;
%template(TemplatePublicDerived3Int) TemplatePublicDerived3<int>;
%template(TemplatePublicDerived4Int) TemplatePublicDerived4<int>;
%template(TemplatePublicDerived5Int) TemplatePublicDerived5<int>;

%inline %{
// Templates and public base constructors (derive from template)
template<typename T>
struct TemplPublicBase1 {
  virtual ~TemplPublicBase1() {}
  TemplPublicBase1(T i, const char* s) {}
  virtual void meth() {}
};

template<typename T>
struct TemplPublicBase2 {
  virtual ~TemplPublicBase2() {}
  TemplPublicBase2(T i, const char* s) {}
  TemplPublicBase2() {}
  virtual void meth() {}
};

template<typename T>
struct TemplPublicBase3 {
  virtual ~TemplPublicBase3() {}
  TemplPublicBase3(T i, const char* s) {}
  TemplPublicBase3() = default;
  virtual void meth() {}
};

template<typename T>
struct TemplPublicBase4 {
  virtual ~TemplPublicBase4() {}
  TemplPublicBase4() = default;
  virtual void meth() {}
};

template<typename T>
struct TemplPublicBase5 {
  virtual ~TemplPublicBase5() {}
  // implicit constructor
  virtual void meth() {}
};

template<typename T>
struct TemplPublicBase6 {
#ifdef SWIG
  // Destructor and constructor declared with template parameters (not allowed in C++20 and later though)
  virtual ~TemplPublicBase6<T>() {}
  TemplPublicBase6<T>(T i, const char* s) {}
  TemplPublicBase6<T>() = default;
#else
  virtual ~TemplPublicBase6() {}
  TemplPublicBase6(T i, const char* s) {}
  TemplPublicBase6() = default;
#endif
  virtual void meth() {}
};
%}

%template(TemplPublicBase1Int) TemplPublicBase1<int>;
%template(TemplPublicBase2Int) TemplPublicBase2<int>;
%template(TemplPublicBase3Int) TemplPublicBase3<int>;
%template(TemplPublicBase4Int) TemplPublicBase4<int>;
%template(TemplPublicBase5Int) TemplPublicBase5<int>;
%template(TemplPublicBase6Int) TemplPublicBase6<int>;

%inline %{
template<typename T>
struct TemplPublicDerived1 : TemplPublicBase1<T> {
  using TemplPublicBase1<T>::TemplPublicBase1;
  using TemplPublicBase1<T>::meth;
};
template<typename T>
struct TemplPublicDerived2 : TemplPublicBase2<T> {
  using TemplPublicBase2<T>::TemplPublicBase2;
  using TemplPublicBase2<T>::meth;
};
template<typename T>
struct TemplPublicDerived3 : TemplPublicBase3<T> {
  using TemplPublicBase3<T>::TemplPublicBase3;
  using TemplPublicBase3<T>::meth;
};
template<typename T>
struct TemplPublicDerived4 : TemplPublicBase4<T> {
  using TemplPublicBase4<T>::TemplPublicBase4;
  using TemplPublicBase4<T>::meth;
};
template<typename T>
struct TemplPublicDerived5 : TemplPublicBase5<T> {
  using TemplPublicBase5<T>::TemplPublicBase5;
  using TemplPublicBase5<T>::meth;
};
template<typename T>
struct TemplPublicDerived6 : TemplPublicBase6<T> {
  using TemplPublicBase6<T>::TemplPublicBase6;
  using TemplPublicBase6<T>::meth;
};
%}

%template(TemplPublicDerived1Int) TemplPublicDerived1<int>;
%template(TemplPublicDerived2Int) TemplPublicDerived2<int>;
%template(TemplPublicDerived3Int) TemplPublicDerived3<int>;
%template(TemplPublicDerived4Int) TemplPublicDerived4<int>;
%template(TemplPublicDerived5Int) TemplPublicDerived5<int>;
%template(TemplPublicDerived6Int) TemplPublicDerived6<int>;


// Templated constructors (public)
%inline %{
struct TemplateConstructor1Base {
  virtual ~TemplateConstructor1Base() {}
public:
  // No implicit constructor
  template <typename T> TemplateConstructor1Base(T t, const char *s) {}
  template <typename T> void template_method(T t, const char *s) {}
  virtual void normal_method() {}
};
%}

%template(TemplateConstructor1Base) TemplateConstructor1Base::TemplateConstructor1Base<int>;
%template(TemplateConstructor1Base) TemplateConstructor1Base::TemplateConstructor1Base<const char *>;
%template(TemplateConstructor1Base) TemplateConstructor1Base::TemplateConstructor1Base<double>;
%template(template_method) TemplateConstructor1Base::template_method<int>;
%template(template_method) TemplateConstructor1Base::template_method<const char *>;

%inline %{
struct TemplateConstructor1Derived : TemplateConstructor1Base {
  using TemplateConstructor1Base::normal_method;
 // Note: The two using declarations below automatically introduce the templated names without an explicit %template(), see allocate.cxx
  using TemplateConstructor1Base::TemplateConstructor1Base;
  using TemplateConstructor1Base::template_method;
};
%}

// Templated constructors (protected)
%inline %{
struct TemplateConstructor2Base {
  virtual ~TemplateConstructor2Base() {}
protected:
  // No implicit constructor
  template <typename T> TemplateConstructor2Base(T t, const char *s) {}
  template <typename T> void template_method(T t, const char *s) {}
  virtual void normal_method() {}
};
%}

%template(TemplateConstructor2Base) TemplateConstructor2Base::TemplateConstructor2Base<int>;
%template(TemplateConstructor2Base) TemplateConstructor2Base::TemplateConstructor2Base<const char *>;
%template(TemplateConstructor2Base) TemplateConstructor2Base::TemplateConstructor2Base<double>;
%template(template_method) TemplateConstructor2Base::template_method<int>;
%template(template_method) TemplateConstructor2Base::template_method<const char *>;

%inline %{
struct TemplateConstructor2Derived : TemplateConstructor2Base {
  using TemplateConstructor2Base::normal_method;
  using TemplateConstructor2Base::TemplateConstructor2Base; // introduces protected constructors
  using TemplateConstructor2Base::template_method; // introduces public templated methods
  TemplateConstructor2Derived() : TemplateConstructor2Base(0, "") {} // provide one public constructor for testing
};
%}
