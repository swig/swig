//
// This header includes all C++ headers required for generated Octave wrapper code.
// Using a single header file allows pre-compilation of Octave headers, as follows:
// * Check out this header file:
//     swig -octave -co octheaders.hpp
// * Pre-compile header file into octheaders.hpp.gch:
//     g++ -c ... octheaders.hpp
// * Use pre-compiled header file:
//     g++ -c -include octheaders.hpp ...
//

#if !defined(SWIG_OCTAVE_OCTHEADERS_HPP)
#define SWIG_OCTAVE_OCTHEADERS_HPP

// Required C headers
#include <assert.h>

// Required C++ headers
#include <cstdlib>
#include <climits>
#include <iostream>
#include <exception>
#include <functional>
#include <complex>
#include <string>
#include <vector>
#include <map>

// Minimal headers to define Octave version
#include <octave/oct.h>
#include <octave/version.h>

// Macro for enabling features which require Octave version >= major.minor.patch
// - Use (OCTAVE_PATCH_VERSION + 0) to handle both '<digit>' (released) and '<digit>+' (in development) patch numbers
#define SWIG_OCTAVE_PREREQ(major, minor, patch) \
  ( (OCTAVE_MAJOR_VERSION<<16) + (OCTAVE_MINOR_VERSION<<8) + (OCTAVE_PATCH_VERSION + 0) >= ((major)<<16) + ((minor)<<8) + (patch) )

// Required Octave headers
#include <octave/Cell.h>
#include <octave/dynamic-ld.h>
#include <octave/oct-env.h>
#include <octave/oct-map.h>
#include <octave/ov-scalar.h>
#include <octave/ov-fcn-handle.h>
#include <octave/parse.h>
#include <octave/interpreter.h>
#include <octave/unwind-prot.h>
#include <octave/call-stack.h>

#endif // !defined(SWIG_OCTAVE_OCTHEADERS_HPP)
