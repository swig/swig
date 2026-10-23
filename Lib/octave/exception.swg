/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg), the SWIG_exception fragment with any support code that it needs and SWIG_RETHROW_OCTAVE_EXCEPTIONS.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

%include <typemaps/exception.swg>

%define SWIG_RETHROW_OCTAVE_EXCEPTIONS
  /* rethrow any exceptions thrown by Octave */
  catch (octave::execution_exception& _e) { throw; }
  catch (octave::exit_exception& _e) { throw; }
  catch (octave::interrupt_exception& _e) { throw; }
%enddef
