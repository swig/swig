%module xxx

namespace ns {
  class OuterClass {
  public:
    template <class T> struct Inner1 {
    };
    Inner1<int> useInner1(const Inner1<int>& inner) { return inner; }

#ifdef SWIG
    %template(T_OuterClassInner1Double) Inner1<double>;
#endif
    int iii;
  };
}
