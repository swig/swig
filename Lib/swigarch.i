/* -----------------------------------------------------------------------------
 * swigarch.i
 *
 * SWIG library file for 64bit code specialization and checking.
 *
 * Use only in extreme cases, when no arch. independent code can be
 * generated
 * 
 * To activate 64-bit architecture specific code, use
 *
 *     swig -DSWIGWORDSIZE64
 *
 * Note that extra checking code will be added to the wrapped code,
 * which will prevent the compilation in a different architecture.
 *
 * If you don't specify the SWIGWORDSIZE (the default case), SWIG will
 * generate architecture independent and/or 32bits code, with no extra
 * checking code added.
 * ----------------------------------------------------------------------------- */

#ifdef SWIGWORDSIZE64
%{
#ifndef LONG_MAX
#include <limits.h>
#endif
#if (__WORDSIZE == 32) || (LONG_MAX == INT_MAX)
# error "SWIG generated code is invalid on this 32-bit architecture, please regenerate without defining SWIGWORDSIZE64"
#endif
%}
#endif
