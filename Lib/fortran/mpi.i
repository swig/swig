/* -------------------------------------------------------------------------
 * mpi.i
 *
 * MPI support for Fortran/C interoperability. Assumes a typedef "HAVE_MPI" is
 * defined in the target code -- add

     %insert("runtime") %{
     #include "myconfig.h"
     %}

 * in your code to guarantee that HAVE_MPI is set correctly.
 *
 * ------------------------------------------------------------------------- */
%{
#ifdef HAVE_MPI
#include <mpi.h>
#endif
%}

/* -------------------------------------------------------------------------
 * \brief MPI Fortran compatibility datatypes
 *
 * Use MPI/Fortran compatibility code to wrap C MPI types, but use ISO-C
 * compatibility layer to pass the Fortran integers (and convert back to native
 * MPI type in the wrapper result code).
 */
%apply int { MPI_Comm };

%typemap(ftype) MPI_Comm
"integer"
%typemap(fin, noblock=1) MPI_Comm {
  $1 = int($input, C_INT)
}
%typemap(fout, noblock=1) MPI_Comm {
  $result = int($1)
}

%typemap(in, noblock=1) MPI_Comm {
%#ifdef HAVE_MPI
  $1 = MPI_Comm_f2c(%static_cast(*$input, MPI_Fint));
%#else
  $1 = *$input;
%#endif
}
%typemap(out, noblock=1) MPI_Comm {
%#ifdef HAVE_MPI
  $result = %static_cast(MPI_Comm_c2f($1), int);
%#else
  $result = $1;
%#endif
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
