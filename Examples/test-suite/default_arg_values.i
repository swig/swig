%module default_arg_values

%inline %{

#ifdef SWIG
// Some compilers warn about 'float v = NULL', so only SWIG sees this peculiarity
// Bad Python wrappers were being generated when NULL used for primitive type
# define NULL_FOR_FLOAT NULL
#else
# define NULL_FOR_FLOAT 0
#endif

struct Display {
  float draw1(float v = NULL_FOR_FLOAT) { return v; }
  float draw2(float *v = NULL_FOR_FLOAT) { return v ? *v : 0; }
  int draw3(int index = 0, const bool interpolate = true) { return interpolate ? index : -index; }
  bool bool0(bool x = 0) { return x; }
  bool bool1(bool x = 1) { return x; }

  typedef bool mybool;
  bool mybool0(mybool x = 0) { return x; }
  bool mybool1(mybool x = 1) { return x; }
};
float* createPtr(float v) { static float val; val = v; return &val; }

%}
