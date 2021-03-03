%module "doxygen_parsing_enums_typesafe"

// Test enum commenting using the typesafe enum pattern in the target language
%include "enumtypesafe.swg"

#define SWIG_TEST_NOCSCONST // For C# typesafe enums

%include "doxygen_parsing_enums.i"