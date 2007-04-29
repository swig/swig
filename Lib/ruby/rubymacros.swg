
// Redefine these macros so argument index for ruby is done properly,
// ignoring self.
#define %argfail_fmt(_type,_name,_argn) \
 Ruby_Format_TypeError( "", _type, #_name, _argn )

#define %argnullref_fmt(_type,_name,_argn) \
 Ruby_Format_TypeError(%nullref_fmt(), _type, #_name, _argn)


%include <typemaps/swigmacros.swg>
