/* rubydec.swg */
#ifdef __cplusplus
extern "C" {
#endif

SWIGIMPORT(void)   SWIG_InitRuntime(void);
SWIGIMPORT(void)   SWIG_define_class(swig_type_info *);
SWIGIMPORT(VALUE)  SWIG_NewPointerObj(void *, swig_type_info *, int);
SWIGIMPORT(VALUE)  SWIG_NewClassInstance(VALUE, swig_type_info *);
SWIGIMPORT(char *) SWIG_MangleStr(VALUE);
SWIGIMPORT(int)    SWIG_ConvertPtr(VALUE, void**, swig_type_info *, int);
SWIGIMPORT(int)    SWIG_CheckConvert(VALUE, swig_type_info *);
SWIGIMPORT(char *) SWIG_PackData(char *c, void *ptr, int sz);
SWIGIMPORT(char *) SWIG_UnpackData(char *c, void *ptr, int sz);
SWIGIMPORT(VALUE)  SWIG_NewPackedObj(void *ptr, int sz, swig_type_info *type);
SWIGIMPORT(void)   SWIG_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty, int flags);

#ifdef __cplusplus
}
#endif
