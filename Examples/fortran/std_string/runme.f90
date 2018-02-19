! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  use, intrinsic :: ISO_C_BINDING
  use stdstr, only : print_str, halve_str, string, create_string, &
    get_reversed_native_string
  implicit none
  character(len=*), parameter :: paramstr = "short string   "
  character(len=:), allocatable :: varlen, tostr
  character(kind=C_CHAR), dimension(:), pointer :: ptrstr
  character(len=16) :: fixedlen
  integer :: i
  type(string) :: s

  write(0, *) "Constructing..."
  s = create_string()
  write(0, *) "Size:", s%size()

  call s%assign_from(trim(paramstr))
  write(0, *) "Assigned from trimmed string:"
  call print_str(s)

  fixedlen = "fixed"
  call s%assign_from(fixedlen)
  write(0, *) "Assigned from fixed-length string:"
  call print_str(s)

  ! Cut it in half and read it back out to varlen
  write(0, *) "Halving..."
  call halve_str(s)

  ptrstr => s%view()
  write(0, *) "String view size:", size(ptrstr)

  ! Get a view of the string as an array of single chars
  call halve_str(s)
  ptrstr => s%view()

  ! NOTE: putting the size call inside the allocate call causes a crash
  write(0, *) "Allocating and copying to varlen"
  i = size(ptrstr)
  allocate(character(len=i) :: varlen)
  do i = 1,len(varlen)
    varlen(i:i) = ptrstr(i)
  enddo

  write(0, *) "Quarter-length string: '"//varlen//"'"

  ! Get using native string output operator
  tostr = s%str()
  write(0, *) "As native allocated string: '"//tostr//"'"

  ! Copy string to fixed-length array (alternate way of extracting)
  fixedlen = "XXXXXXXXXXXXXXXX"
  call s%copy_to(fixedlen)
  write(0, *) "Fixed-length string: '"//fixedlen//"'"

  write(0, *) "Destroying..."
  call s%release()

  write(0, *) "Calling deallocate"
  deallocate(varlen)
  write(0, *) "Calling deallocate"
  deallocate(tostr)

  write(0, *) "Reversing"
  varlen = "Through the looking glass"
  tostr = get_reversed_native_string(varlen)

  write(0, *) "'"//varlen//"' -> '"//tostr//"'"
end program


!-----------------------------------------------------------------------------!
! end of std_string/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
