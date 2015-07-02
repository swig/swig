/* This testcase checks whether SWIG correctly parses alias templates. */
%module cpp11_template_typedefs

%warnfilter(SWIGWARN_CPP11_ALIAS_TEMPLATE) TypedefName;
%warnfilter(SWIGWARN_CPP11_ALIAS_TEMPLATE) TypedefNamePtr;
%warnfilter(SWIGWARN_CPP11_ALIAS_TEMPLATE) MyIntKeyClass;
%warnfilter(SWIGWARN_CPP11_ALIAS_DECLARATION) PF;
%warnfilter(SWIGWARN_CPP11_ALIAS_DECLARATION) BucketAllocator1;
%warnfilter(SWIGWARN_CPP11_ALIAS_DECLARATION) BucketAllocator2;

// This warning should go away when type aliasing is supported
#pragma SWIG nowarn=SWIGWARN_PARSE_USING_UNDEF // Nothing known about 'p.SomeType< char *,T2,4 >'.

%inline %{
template< typename T1, typename T2, int >
class SomeType {
  T1 a;
  T2 b;
  int c;
};

// template aliasing
template< typename T2 >
using TypedefName = SomeType<char*, T2, 5>;
template< typename T2 >
using TypedefNamePtr = SomeType<char*, T2, 4>*;

// type aliasing
typedef void (*PFD)(double);            // Old style
using PF = void (*)(double);            // New introduced syntax


// use of template aliasing
template<typename Key,typename Val>
class MyCPP11Class {
};
template<typename VAL> using MyIntKeyClass = MyCPP11Class<int,VAL>;
MyIntKeyClass<char> intchar;

TypedefName<int> alias1(TypedefName<int> a) { return a; }
TypedefNamePtr<int> alias1(TypedefNamePtr<int> a = nullptr) { return a; }
%}

%inline %{
typedef double Val;
template<typename T> struct ListBucket {
};
namespace Alloc {
  template<typename T> struct rebind {
    typedef int other;
  };
}

using BucketAllocator1 = typename Alloc::template rebind<ListBucket<Val>>::other;
using BucketAllocator2 = typename Alloc::template rebind<::template ListBucket<double>>::other;
%}
