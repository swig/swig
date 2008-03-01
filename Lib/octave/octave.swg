

%include <typemaps/swigmacros.swg>
%include <typemaps/fragments.swg>
%include <octruntime.swg>
%include <octtypemaps.swg>
%include <octopers.swg>


%typemap(constcode) int double {
  SWIG_Octave_SetConstant(module_ns,"$symname",octave_value($value));
}
