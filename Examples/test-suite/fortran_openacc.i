%module fortran_openacc

// Mock 'thrust'
%{
#include <numeric>
%}

%include <openacc.i>
%include <thrust.i>

%inline %{
int thrust_accumulate(thrust::device_ptr<int> DATA, size_t SIZE) {
  return std::accumulate(raw_pointer_cast(DATA), raw_pointer_cast(DATA) + SIZE, 0);
}
%}

%insert("fbegin") %{
module openacc
 use, intrinsic :: ISO_C_BINDING
 implicit none
 type, bind(C) :: C_DEVPTR
  type(C_PTR), public :: p = C_NULL_PTR
 end type
 type(C_DEVPTR), parameter :: C_NULL_DEVPTR = C_DEVPTR(C_NULL_PTR)
contains
  function acc_deviceptr(data) &
    result(devptr)
    integer(C_INT), dimension(:), target :: data
    type(C_DEVPTR) :: devptr
    devptr%p = c_loc(data(1))
  end function
end module
%}

