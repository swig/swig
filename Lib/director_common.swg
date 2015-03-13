/* -----------------------------------------------------------------------------
 * director_common.swg
 *
 * This file contains support for director classes which is common between
 * languages.
 * ----------------------------------------------------------------------------- */

/*
  Use -DSWIG_DIRECTOR_STATIC if you prefer to avoid the use of the
  'Swig' namespace. This could be useful for multi-modules projects.
*/
#ifdef SWIG_DIRECTOR_STATIC
/* Force anonymous (static) namespace */
#define Swig
#endif

/*
 Use -DSWIG_DIRECTOR_THROW to do something else than throw a C++ exception when
 it has an exception to raise.
*/
#ifndef SWIG_DIRECTOR_THROW
#define SWIG_DIRECTOR_THROW(e) throw e
#endif

/*
 Use -DSWIG_DIRECTOR_RETHROW to do something else than throw a C++ exception
 when rethrowing a C++ exception.
*/
#ifndef SWIG_DIRECTOR_RETHROW
#define SWIG_DIRECTOR_RETHROW throw
#endif

