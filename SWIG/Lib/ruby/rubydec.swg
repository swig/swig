/* rubydec.swg */
#ifdef __cplusplus
extern "C" {
#endif

SWIGIMPORT(void)   SWIG_InitRuntime(void);
SWIGIMPORT(void)   SWIG_define_class(swig_type_info *);
SWIGIMPORT(VALUE)  SWIG_NewPointerObj(void *, swig_type_info *, int own);
SWIGIMPORT(char *) SWIG_MangleStr(VALUE);
SWIGIMPORT(void *) SWIG_ConvertPtr(VALUE, swig_type_info *);
SWIGIMPORT(int)    SWIG_CheckConvert(VALUE, swig_type_info *);

#ifdef __cplusplus
}
#endif
