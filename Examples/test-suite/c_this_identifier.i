/* This testcase checks that 'this' stays an ordinary identifier in C - it is a C++ keyword and SWIG
   returns a keyword token for it when parsing C++ only. */
%module c_this_identifier

%{
int this_plus_one(int v) { return v + 1; }
%}

/* A parameter named 'this' is parsed but never spelt in the generated wrapper. */
int this_plus_one(int this);

/* A global variable, a member and a local named 'this' are spelt in the wrapper, which Octave and
   Javascript (v8/napi) compile as C++ even for a C interface. */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI)

/* SWIG renames a target language keyword itself, but the test suite's -Werror makes that warning fatal
   and the name it picks varies by language, so rename explicitly for the runme tests.  Q::this must be
   renamed anyway as it would otherwise hide the Python proxy class's own 'this' attribute. */
%rename(this_value) Q::this;
%rename(this_global) ::this;

%inline %{
struct Q {
  int this;
};

int this = 40;

int this_local(void) {
  int this = 41;
  return this + 1;
}
%}
#endif
