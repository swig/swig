/* SWIG Configuration File for MzScheme. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "mzschemedec.swg"

/*#ifndef SWIG_NOINCLUDE*/
%insert(runtime) "mzscheme.swg"
/*#endif*/

/* Read in standard typemaps. */
%include "typemaps.i"

