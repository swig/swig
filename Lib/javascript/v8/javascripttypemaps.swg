#define SWIG_Object                     v8::Handle<v8::Value>
#define VOID_Object                     v8::Undefined()
#define SWIG_AppendOutput(result, obj)
#define SWIG_SetConstant(name, obj)
#define SWIG_Raise(obj, type, desc)  SWIG_V8_Raise(type)

/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Python fragments for fundamental types */
%include <javascriptprimitives.swg>
 
%include <javascriptstrings.swg>

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>
