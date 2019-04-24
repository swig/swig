// Tests SWIG's *default* handling of overloading varargs (function varargs, not preprocessor varargs).
// The default behavior is to simply ignore the varargs.
%module varargs_overload

%inline %{
#include <stdio.h>

const char *vararg_over1(const char *fmt, ...) {
  return fmt;
}
const char *vararg_over1(int i) {
  static char buffer[256];
  sprintf(buffer, "%d", i);
  return buffer;
}

const char *vararg_over2(const char *fmt, ...) {
  return fmt;
}
const char *vararg_over2(int i, double j) {
  static char buffer[256];
  sprintf(buffer, "%d %g", i, j);
  return buffer;
}

const char *vararg_over3(const char *fmt, ...) {
  return fmt;
}
const char *vararg_over3(int i, double j, const char *s) {
  static char buffer[256];
  sprintf(buffer, "%d %g %s", i, j, s);
  return buffer;
}
%}

%varargs(int mode = 0) vararg_over4;
%inline %{
const char *vararg_over4(const char *fmt, ...) {
  return fmt;
}
const char *vararg_over4(int i) {
  static char buffer[256];
  sprintf(buffer, "%d", i);
  return buffer;
}
%}


// Same as above but non-vararg function declared first

%inline %{
const char *vararg_over6(int i) {
  static char buffer[256];
  sprintf(buffer, "%d", i);
  return buffer;
}
const char *vararg_over6(const char *fmt, ...) {
  return fmt;
}

const char *vararg_over7(int i, double j) {
  static char buffer[256];
  sprintf(buffer, "%d %g", i, j);
  return buffer;
}
const char *vararg_over7(const char *fmt, ...) {
  return fmt;
}

const char *vararg_over8(int i, double j, const char *s) {
  static char buffer[256];
  sprintf(buffer, "%d %g %s", i, j, s);
  return buffer;
}
const char *vararg_over8(const char *fmt, ...) {
  return fmt;
}
%}

%varargs(int mode = 0) vararg_over9;
%inline %{
const char *vararg_over9(int i) {
  static char buffer[256];
  sprintf(buffer, "%d", i);
  return buffer;
}
const char *vararg_over9(const char *fmt, ...) {
  return fmt;
}
%}
