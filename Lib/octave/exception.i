%include <typemaps/exception.swg>

%define SWIG_RETHROW_OCTAVE_EXCEPTIONS
  /* rethrow any exceptions thrown by Octave */
  catch (octave::execution_exception& _e) { throw; }
  catch (octave::exit_exception& _e) { throw; }
  catch (octave::interrupt_exception& _e) { throw; }
%enddef
