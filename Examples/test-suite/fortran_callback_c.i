%module fortran_callback_c

%fortranbindc;

// Ignore warning about callbacks (since we're doing fortranbindc for everything)
%warnfilter(SWIGWARN_FORTRAN_IGNORE_CALLBACK) add;
%warnfilter(SWIGWARN_FORTRAN_IGNORE_CALLBACK) mul;

%include "fortran_callback.i"

