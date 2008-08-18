/* File : example.h */

// Some template definitions

/*! Template class T 
 \author cmfoil 
 \sa something something */

template<class T> T max(T a, T b) { return  a>b ? a : b; }

/*! Template class Vector 
 \author cmfoil 
 \sa something something */
template<class T> class vector {
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
  } /*!< Something about set */
#ifdef SWIG
  %extend {
    T getitem(int index) {
      return $self->get(index);
    }/*!< Something about get item */
    void setitem(int index, T val) {
      $self->set(index,val);
    }
  }
#endif
};

