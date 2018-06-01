/* File: mpitest.i */

%module mpitest

%{
#define HAVE_MPI
%}
%include <mpi.i>

%inline %{
/* Automatically generate accessors to these */
MPI_Comm global_comm = MPI_COMM_NULL;
MPI_Comm split_comm  = MPI_COMM_NULL;

int global_rank() {
    int rank = -1;
    MPI_Comm_rank(global_comm, &rank);
    return rank;
}

void split_even_odd() {
    /* split into even/odd */
    int color = global_rank() % 2;
    MPI_Comm_split(global_comm, color, 0, &split_comm);
}
%}


