/* rubydec.swg */
#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT(void)   SWIG_RegisterMapping(char *origtype, char *newtype, void *(*cast)(void *));
SWIGEXPORT(void)   SWIG_MakePtr(char *_c, const void *_ptr, char *type);
SWIGEXPORT(char *) SWIG_GetPtr(char *_c, void **ptr, char *_t);
SWIGEXPORT(VALUE)  SWIG_NewPointerObj(void *ptr, char *type);
SWIGEXPORT(void *) SWIG_ConvertPtr(VALUE obj, char *type);

#ifdef __cplusplus
}
#endif

