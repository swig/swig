/* This testcase checks whether SWIG correctly handles alias templates. */
%module cpp11_template_typedefs

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) space1::Outer::Inner;

%inline %{

template<typename T>
using ptr_t = T*;

namespace ns {

template<typename T1, typename T2, int N>
class SomeType {
public:
  using type1_t = T1;
  using type2_t = T2;
  T1 a;
  T2 b;
  constexpr int get_n() const { return N; }
};

// Specialization for T1=const char*, T2=bool
template<int N>
class SomeType<const char*, bool, N> {
public:
  using type1_t = const char*;
  using type2_t = bool;
  type1_t a;
  type2_t b;
  constexpr int get_n() const { return 3 * N; }
};

// alias templates
template<typename T2>
using TypedefName = SomeType<const char*, T2, 5>;
template<typename T2>
using TypedefNamePtr = ptr_t<SomeType<const char*, T2, 4>>;

// alias template that returns T2 for a SomeType<T1,T2,N> class
template<typename T>
using T2_of = typename T::type2_t;

T2_of<TypedefName<int>> get_SomeType_b(const SomeType<const char*, int, 5>& x) { return x.b; }

template<typename T>
T2_of<TypedefName<T>> get_SomeType_b2(const TypedefName<T>& x) { return x.b; }

} // namespace ns

ns::TypedefName<int> create_TypedefName() { return { "hello", 10}; }
ns::TypedefName<bool> create_TypedefNameBool() { return { "hello", true}; }
ns::TypedefNamePtr<int> identity(ns::TypedefNamePtr<int> a = nullptr) { return a; }

typedef double Val;
template<typename T> struct ListBucket {
};
namespace Alloc {
  template<typename T> struct rebind {
    using other = int;
  };
}

using BucketAllocator1 = typename Alloc::template rebind<ListBucket<Val>>::other;
using BucketAllocator2 = typename Alloc::template rebind<::template ListBucket<double>>::other;

BucketAllocator1 get_bucket_allocator1() { return 1; }
BucketAllocator2 get_bucket_allocator2() { return 2; }

// Regression test for #3526.  An alias declaration of a template instantiation is used as the scope
// qualifier of a template argument.  The scope of the argument type was added twice, generating
// space1::space1::Point and the like, which did not compile.  Holder has no default constructor, so
// the argument type is also emitted in a SwigValueWrapper declaration in the generated code.
namespace space1 {
  struct Point { int x; };
  struct Outer {
    struct Inner { int x; };
  };
  template <typename T> struct Holder {
    using size_type = int;
    Holder(T v) {}
  };
  // Control: the alias is declared in a class, where the argument type is not qualified yet when it
  // is looked up, so the scope does still have to be added.
  struct InClass {
    typedef Holder<Point> PointHolder;
    typedef Holder<PointHolder::size_type> SizeHolder;
    SizeHolder qualifier_in_class(SizeHolder h) { return h; }
  };
}

namespace space2 {
  namespace space3 {
    struct DeepPoint { int x; };
  }
}

// Template argument is a class in a namespace.
using PointHolder = space1::Holder<space1::Point>;
using PointSizeHolder = space1::Holder<PointHolder::size_type>;
PointSizeHolder qualifier_namespace(PointSizeHolder h) { return h; }

// Template argument is a nested class.
using InnerHolder = space1::Holder<space1::Outer::Inner>;
using InnerSizeHolder = space1::Holder<InnerHolder::size_type>;
InnerSizeHolder qualifier_nested_class(InnerSizeHolder h) { return h; }

// Template argument is a class in a nested namespace.
using DeepHolder = space1::Holder<space2::space3::DeepPoint>;
using DeepSizeHolder = space1::Holder<DeepHolder::size_type>;
DeepSizeHolder qualifier_nested_namespace(DeepSizeHolder h) { return h; }
%}

%immutable ns::SomeType::a;

// %template() directives

%template(SomeTypeInt5) ns::SomeType<const char*, int, 5>;
%template(SomeTypeInt4) ns::SomeType<const char*, int, 4>;
%template(SomeTypeBool5) ns::SomeType<const char*, bool, 5>;

%template(ListBucketDouble) ListBucket<Val>;
%template(RebindListBucketDouble) Alloc::rebind<ListBucket<Val>>;

%template() ptr_t<ns::SomeType<const char*, int, 4>>;
%template() ns::TypedefName<int>;
%template() ns::TypedefName<bool>;
%template() ns::TypedefNamePtr<int>;
%template() ns::T2_of<ns::TypedefName<int>>;

%template(get_SomeType_b2) ns::get_SomeType_b2<int>;
