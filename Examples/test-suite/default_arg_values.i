%module default_arg_values

%{
struct Display {
  // Some compilers warn about 'float v = NULL', so only SWIG sees this peculiarity
  // Bad Python wrappers were being generated when NULL used for primitive type
  float draw1(float v = 0) { return v; }
  float draw2(float *v = 0) { return v ? *v : 0; }
};
float* createPtr(float v) { static float val; val = v; return &val; }
%}

struct Display {
  // Bad Python wrappers were being generated when NULL used for primitive type
  float draw1(float v = NULL) { return v; }
  float draw2(float *v = NULL) { return v ? *v : 0; }
};
float* createPtr(float v) { static float val; val = v; return &val; }
