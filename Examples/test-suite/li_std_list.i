%module li_std_list

%include "std_list.i"
%include "std_string.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

%template(BoolList) std::list<bool>;
%template(CharList) std::list<char>;
%template(ShortList) std::list<short>;
%template(IntList) std::list<int>;
%template(LongList) std::list<long>;
%template(UCharList) std::list<unsigned char>;
%template(UIntList) std::list<unsigned int>;
%template(UShortList) std::list<unsigned short>;
%template(ULongList) std::list<unsigned long>;
%template(FloatList) std::list<float>;
%template(DoubleList) std::list<double>;
%template(StringList) std::list<std::string>;

%inline %{

double average(std::list<int> v) {
    return std::accumulate(v.begin(),v.end(),0.0)/v.size();
}


void halve_in_place(std::list<double>& v) {
    for (std::list<double>::iterator it = v.begin(); it != v.end(); ++it)
        *it /= 2.0;
}

struct Struct {
  double num;
  Struct() : num(0.0) {}
  Struct(double d) : num(d) {}
};

const std::list<Struct> & CopyContainerStruct(const std::list<Struct> & container) { return container; }
const std::list<Struct *> & CopyContainerStructPtr(const std::list<Struct *> & container) { return container; }
const std::list<const Struct *> & CopyContainerStructConstPtr(const std::list<const Struct *> & container) { return container; }

const std::list<float> & listreal(const std::list<float> & list) { return list; }
           
const std::list<int> & listint(const std::list<int> & list) { return list; }
const std::list<int *> & listintptr(const std::list<int *> & list) { return list; }
const std::list<const int *> & listintconstptr(const std::list<const int *> & list) { return list; }
           
const std::list<Struct> & liststruct(const std::list<Struct> & list) { return list; }
const std::list<Struct *> & liststructptr(const std::list<Struct *> & list) { return list; }
const std::list<const Struct *> & liststructconstptr(const std::list<const Struct *> & list) { return list; }

enum Fruit {
  APPLE,
  BANANNA,
  PEAR,
  KIWI,
};
%}

#if !defined(SWIGR)
%template(IntPtrList) std::list<int *>;
%template(IntConstPtrList) std::list<const int *>;
#endif
%template(StructList) std::list<Struct>;
%template(StructPtrList) std::list<Struct *>;
%template(StructConstPtrList) std::list<const Struct *>;
%template(FruitList) std::list<enum Fruit>;
