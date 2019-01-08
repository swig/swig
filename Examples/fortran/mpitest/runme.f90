! File : example_runme.f90

program example_runme
  use example
  use mpi
  use ISO_C_BINDING
  implicit none
  integer :: ierr, rank, size, srank, ssize, split_comm

  call mpi_init(ierr)

  ! Copy global comm to C side
  call set_global_comm(MPI_COMM_WORLD)

  ! Split and get the MPIF handle for it
  call split_even_odd()
  split_comm = get_split_comm()

  ! Get the split communicator
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(split_comm, srank, ierr)
  call mpi_comm_size(split_comm, ssize, ierr)
  call mpi_barrier(MPI_COMM_WORLD, ierr)
  write(*, '("Global:", i2, "/", i2, ", split:", i2, "/", i2)') &
    rank, size, srank, ssize

  call mpi_finalize(ierr)
end program


