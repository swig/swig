/* -*- c -*-
   This SWIG interface file is processed if the Guile module is run
   with gh_ flavor.
*/

#define SWIGGUILE_GH

%runtime "guile_gh_run.swg"
%include "guile.i"

%init %{
  static int _swig_init = 0;

  if (!_swig_init) {
    SWIG_Guile_Init();
    SWIG_Guile_RegisterTypes(swig_types, swig_types_initial);
    _swig_init = 1;
  }

%}
