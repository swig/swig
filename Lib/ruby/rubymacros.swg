
// Redefine these macros so argument index for ruby is done properly,
// ignoring self and we get some more info about the input.
#define %argfail_fmt(_type,_name,_argn) Ruby_Format_TypeError( "", _type, #_name, _argn, $input )

#define %argnullref_fmt(_type,_name,_argn) Ruby_Format_TypeError(%nullref_fmt(), _type, #_name, _argn, $input)


%include <typemaps/swigmacros.swg>
