%include <std/std_except.i>
%include <pystdcommon.swg>
%include <std/std_common.i>

//
// Generates the traits for all the known primitive
// C++ types (int, double, ...)
//
%apply_cpptypes(%traits_ptypen);

