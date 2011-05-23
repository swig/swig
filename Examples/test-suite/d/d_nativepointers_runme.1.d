module d_nativepointers_runnme;

import d_nativepointers.d_nativepointers;
import d_nativepointers.SomeClass;
import d_nativepointers.SWIGTYPE_p_OpaqueClass;
import d_nativepointers.SWIGTYPE_p_p_SomeClass;
import d_nativepointers.SWIGTYPE_p_p_f_p_p_int_p_SomeClass__void;

void main() {
  check!(a, int*);
  check!(b, float**);
  check!(c, char***);
  check!(d, SomeClass);
  check!(e, SWIGTYPE_p_p_SomeClass);
  check!(f, SWIGTYPE_p_OpaqueClass);
  check!(g, void function(int**, char***));
  check!(h, SWIGTYPE_p_p_f_p_p_int_p_SomeClass__void);

  {
    static assert(is(int* function(int*) == typeof(&refA)));
    int v = 2;
    assert(*refA(&v) == 2);
  }

  {
    static assert(is(float** function(float**) == typeof(&refB)));
    float v = 1.0;
    float* p = &v;
    assert(**refB(&p) == 1.0);
  }
}

void check(alias F, T)() {
  static assert(is(T function(T) == typeof(&F)));
  assert(F(null) is null);
}
