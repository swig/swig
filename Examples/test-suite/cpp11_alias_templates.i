%module cpp11_alias_templates

// C++11 alias templates focused test.  Demonstrates the documented wrapping
// pattern: instantiate the underlying template with %template(Name), then
// register each alias with an empty %template().  Each alias resolves to its
// underlying instantiated template in the target language.

%inline %{
template<typename T>
class Container {
  T v;
public:
  Container() : v(T()) {}
  Container(T x) : v(x) {}
  T get() const { return v; }
  void set(T x) { v = x; }
};

// 1. Simple alias template.
template<typename T>
using Box = Container<T>;

// 2. Alias-of-alias: SWIG must resolve through both levels.
template<typename T>
using Boxed = Box<T>;

// 3. Alias template fixing a non-type parameter of the underlying template.
template<typename T, int N>
class FixedArray {
  T data[N];
public:
  int size() const { return N; }
  void set(int i, T x) { if (0 <= i && i < N) data[i] = x; }
  T get(int i) const { return (0 <= i && i < N) ? data[i] : T(); }
};

template<typename T>
using Quad = FixedArray<T, 4>;

Box<int>    make_box  (int v)  { return Box<int>(v); }
Boxed<int>  make_boxed(int v)  { return Boxed<int>(v); }
Quad<float> make_quad ()       { return Quad<float>(); }
%}

%template(ContainerInt) Container<int>;
%template()             Box<int>;
%template()             Boxed<int>;

%template(FixedArrayFloat4)  FixedArray<float, 4>;
%template()             Quad<float>;
