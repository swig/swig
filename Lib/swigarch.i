/* -----------------------------------------------------------------------------
 * swigarch.i
 *
 * SWIG library file for 32bit/64bit code specialization and checking.
 *
 * Use only in extreme cases, when no arch. independent code can be
 * generated
 * 
 * To activate 32-bit architecture checks, use
 *
 *     swig -DSWIGWORDSIZE32
 *
 * This adds checks that long is 32-bits when compiling the generated wrappers.
 *
 * To activate 64-bit architecture specific code, use
 *
 *     swig -DSWIGWORDSIZE64
 *
 * This adds checks that long is 64-bits when compiling the generated wrappers.
 * Some target languages also generate code that expects long to be 64-bits.
 *
 * If you don't specify the SWIGWORDSIZE (the default case), SWIG will
 * generate architecture independent and/or 32bits code, with no extra
 * checks for the sizeof long.
 * ----------------------------------------------------------------------------- */

#ifdef SWIGWORDSIZE32
%fragment("long_check_wordsize32");
#endif

#ifdef SWIGWORDSIZE64
%fragment("long_check_wordsize64");
#endif
