/* rubydec.swg -*- c -*- */
#ifdef __cplusplus
extern "C" {
#endif

SWIGIMPORT(void)   SWIG_Ruby_InitRuntime(void);
SWIGIMPORT(void)   SWIG_Ruby_define_class(swig_type_info *);
SWIGIMPORT(VALUE)  SWIG_Ruby_NewPointerObj(void *, swig_type_info *, int);
SWIGIMPORT(VALUE)  SWIG_Ruby_NewClassInstance(VALUE, swig_type_info *);
SWIGIMPORT(char *) SWIG_Ruby_MangleStr(VALUE);
SWIGIMPORT(int)    SWIG_Ruby_ConvertPtr(VALUE, void**, swig_type_info *, int);
SWIGIMPORT(void *) SWIG_Ruby_MustGetPtr(VALUE, swig_type_info *, int, int);
SWIGIMPORT(int)    SWIG_Ruby_CheckConvert(VALUE, swig_type_info *);
SWIGIMPORT(VALUE)  SWIG_Ruby_NewPackedObj(void *ptr, int sz, swig_type_info *type);
SWIGIMPORT(void)   SWIG_Ruby_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty, int flags);

#ifdef __cplusplus
}
#endif
