%module li_std_list

%include "std_list.i"
%include "std_string.i"

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}

#if 1
#if defined(SWIGJAVA) && JAVA_VERSION_MAJOR < 21
// Test these methods which were removed in swig-4.0 as JDK added the same methods
// in the java.util.AbstractSequentialList base but unfortunately two of them use
// a different return type.
%extend std::list {
  void removeLast() { $self->pop_back(); }
  void removeFirst() { $self->pop_front(); }
  void addLast(const T &value) { $self->push_back(value); }
  void addFirst(const T &value) { $self->push_front(value); }
}
#endif
#else
// Alternative implementation suggested in https://github.com/swig/swig/issues/3156
%extend std::list {
%proxycode %{
  public $typemap(jboxtype, T) removeLast() {
    if (this.isEmpty()) {
      throw new java.util.NoSuchElementException();
    } else {
      return this.remove(this.size() - 1);
    }
  }

  public $typemap(jboxtype, T) removeFirst() {
    if (this.isEmpty()) {
      throw new java.util.NoSuchElementException();
    } else {
      return this.remove(0);
    }
  }

  public void addLast($typemap(jboxtype, T) value) {
    this.add(value);
  }

  public void addFirst($typemap(jboxtype, T) value) {
    this.add(0, value);
  }
%}
}
#endif

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
