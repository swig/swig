%module xxx

%typemap(in, numinputs=1, foo) int ""
%typemap(argout=123) char* ""

/* SWIG segfaulted trying to use the above in typemap in SWIG < 4.1.0. */
void func(int arg);
