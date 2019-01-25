/* -------------------------------------------------------------------------
 * fortranfragments.swg
 * -------------------------------------------------------------------------
  Create a file with this name, 'fortranfragments.swg', in your working
  directory and add all the %fragments you want to take precedence
  over the default ones defined by SWIG.

  For example, if you want to replace how the Fortran logical type is converted
  to the SWIG integer type, you could add:

    %fragment("SWIG_logical_to_int_f", "fsubprograms",
              noblock="1") {
    function SWIG_logical_to_int(inp) &
        result(out)
      use, intrinsic :: ISO_C_BINDING
      logical, intent(IN) :: inp
      integer(kind=C_INT) :: out
      <your code here>
    end function
    }
*/

