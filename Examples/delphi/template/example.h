/* File : example.h */

/* Let's define a function template: */
template<class T> T max(T a, T b) { return  a>b ? a : b; }

/* TODO -oSMK : And a class template */
/* template<class T> class vector {
  T *v;
  int sz;
 public:
  vector(int _sz) {
    v = new T[_sz];
    sz = _sz;
  }
  T &get(int index) {
    return v[index];
  }
  void set(int index, T &val) {
    v[index] = val;
  }
#ifdef SWIG
  %extend {
    T getitem(int index) {
      return $self->get(index);
    }
    void setitem(int index, T val) {
      $self->set(index,val);
    }
  }
#endif
}
*/;