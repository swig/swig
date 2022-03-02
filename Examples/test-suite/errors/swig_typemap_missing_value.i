%module xxx

%typemap(in, numinputs=1, foo) int ""

/* SWIG segfaulted trying to use the above typemap in SWIG < 4.1.0. */
void func(int arg);
