
%insert(runtime) "javahead.swg"

/* Java typemaps.
 * The jni, jtype and jstype typemaps work together and so there should be one of each. 
 * The jni typemap contains the JNI type used in the JNI (C/C++) code. 
 * The jtype typemap contains the Java type used in the Java module class. 
 * The jstype typemap contains the Java type used in the Java shadow class. */

/* Primitive types */
%typemap(jni) char             "jbyte"
%typemap(jni) signed char      "jbyte"
%typemap(jni) unsigned char    "jshort"
%typemap(jni) short            "jshort"
%typemap(jni) unsigned short   "jint"
%typemap(jni) int              "jint"
%typemap(jni) unsigned int     "jlong"
%typemap(jni) long             "jlong"
%typemap(jni) unsigned long    "jlong"
%typemap(jni) float            "jfloat"
%typemap(jni) double           "jdouble"
%typemap(jni) bool             "jboolean"
%typemap(jni) char *           "jstring"
%typemap(jni) void             "void"

%typemap(jtype) char            "byte"
%typemap(jtype) signed char     "byte"
%typemap(jtype) unsigned char   "short"
%typemap(jtype) short           "short"
%typemap(jtype) unsigned short  "int"
%typemap(jtype) int             "int"
%typemap(jtype) unsigned int    "long"
%typemap(jtype) long            "long"
%typemap(jtype) unsigned long   "long"
%typemap(jtype) float           "float"
%typemap(jtype) double          "double"
%typemap(jtype) bool            "boolean"
%typemap(jtype) char *          "String"
%typemap(jtype) void            "void"

%typemap(jstype) char           "byte"
%typemap(jstype) signed char    "byte"
%typemap(jstype) unsigned char  "short"
%typemap(jstype) short          "short"
%typemap(jstype) unsigned short "int"
%typemap(jstype) int            "int"
%typemap(jstype) unsigned int   "long"
%typemap(jstype) long           "long"
%typemap(jstype) unsigned long  "long"
%typemap(jstype) float          "float"
%typemap(jstype) double         "double"
%typemap(jstype) bool           "boolean"
%typemap(jstype) char *         "String"
%typemap(jstype) void           "void"

/* Arrays of primtive types */                     
%typemap(jni) char[ANY]           "jbyteArray"
%typemap(jni) signed char[ANY]    "jbyteArray"
%typemap(jni) unsigned char[ANY]  "jshortArray"
%typemap(jni) short[ANY]          "jshortArray"
%typemap(jni) unsigned short[ANY] "jintArray"
%typemap(jni) int[ANY]            "jintArray"
%typemap(jni) unsigned int[ANY]   "jlongArray"
%typemap(jni) long[ANY]           "jlongArray"
%typemap(jni) unsigned long[ANY]  "jlongArray"
%typemap(jni) float[ANY]          "jfloatArray"
%typemap(jni) double[ANY]         "jdoubleArray"
%typemap(jni) bool[ANY]           "jbooleanArray"
//%typemap(jni="jstring")  char *                     
//%typemap(jni="void")     void                     

%typemap(jtype) char[ANY]           "byte[]"
%typemap(jtype) signed char[ANY]    "byte[]"
%typemap(jtype) unsigned char[ANY]  "short[]"
%typemap(jtype) short[ANY]          "short[]"
%typemap(jtype) unsigned short[ANY] "int[]"
%typemap(jtype) int[ANY]            "int[]"
%typemap(jtype) unsigned int[ANY]   "long[]"
%typemap(jtype) long[ANY]           "long[]"
%typemap(jtype) unsigned long[ANY]  "long[]"
%typemap(jtype) float[ANY]          "float[]"
%typemap(jtype) double[ANY]         "double[]"
%typemap(jtype) bool[ANY]           "boolean[]"
//%typemap(jtype="String")  char *                     
//%typemap(jtype="void")    void                     

%typemap(jstype) char[ANY]            "byte[]"
%typemap(jstype) signed char[ANY]     "byte[]"
%typemap(jstype) unsigned char[ANY]   "short[]"
%typemap(jstype) short[ANY]           "short[]"
%typemap(jstype) unsigned short[ANY]  "int[]"
%typemap(jstype) int[ANY]             "int[]"
%typemap(jstype) unsigned int[ANY]    "long[]"
%typemap(jstype) long[ANY]            "long[]"
%typemap(jstype) unsigned long[ANY]   "long[]"
%typemap(jstype) float[ANY]           "float[]"
%typemap(jstype) double[ANY]          "double[]"
%typemap(jstype) bool[ANY]            "boolean[]"
//%typemap(jstype="String")  char *                     
//%typemap(jstype="void")    void                     

/* Non primitive types */
%typemap(jni) SWIGTYPE "jlong"
%typemap(jtype) SWIGTYPE "long"
%typemap(jstype) SWIGTYPE "$javaclassname"
// change to $1_javaclassname???

%typemap(jni) SWIGTYPE [] "jlongArray"
%typemap(jtype) SWIGTYPE [] "long[]"
%typemap(jstype) SWIGTYPE [] "$javaclassname[]"

%typemap(jni) SWIGTYPE * "jlong"
%typemap(jtype) SWIGTYPE * "long"
%typemap(jstype) SWIGTYPE * "long"

%typemap(jni) SWIGTYPE & "jlong"
%typemap(jtype) SWIGTYPE & "long"
%typemap(jstype) SWIGTYPE & "long"

%typemap(jni) SWIGTYPE & CLASS "jlong"
%typemap(jtype) SWIGTYPE & CLASS "long"
%typemap(jstype) SWIGTYPE & CLASS "$javaclassname"

%typemap(jni) enum SWIGTYPE "jint"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "int"

/* Arrays of pointers. SWIG doesn't have a default for pointers to arrays, 
 * eg SWIGTYPE *[]. The typemap SWIGTYPE [] is used for all arrays. The
 * typemaps below give some support for arrays of pointers. */
%typemap(jni) SWIGTYPE *ARRAYSOFPOINTERS[ANY] "jlongArray"
%typemap(jtype) SWIGTYPE *ARRAYSOFPOINTERS[ANY] "long[]"
%typemap(jstype) SWIGTYPE *ARRAYSOFPOINTERS[ANY] "long[]"
%apply SWIGTYPE *ARRAYSOFPOINTERS[ANY] { 
    bool *[ANY], char *[ANY], unsigned char *[ANY], short *[ANY], unsigned short *[ANY], int *[ANY], unsigned int *[ANY], long *[ANY], unsigned long *[ANY], float *[ANY], double *[ANY], void *[ANY] };

/* Arrays of enums. SWIG does not have a default for arrays of enums, eg enum SWIGTYPE []. The following 
 * typemaps are applied in the source code for all enum declarations that is the equivalent of:
 * %apply enum SWIGTYPE[ANY] {name[ANY]}; */
%typemap(jni) enum SWIGTYPE[ANY] "jintArray"
%typemap(jtype) enum SWIGTYPE[ANY] "int[]"
%typemap(jstype) enum SWIGTYPE[ANY] "int[]"

/* Pointers and references to classes. SWIG does not have a default for pointers to classes, eg SWIGTYPE *CLASS. 
 * The following typemaps are applied in the source code for all class/struct/union declarations, that is the equivalent of:
 * %apply SWIGTYPE *CLASS { name * }; 
 * %apply SWIGTYPE &CLASS { name & }; */
%typemap(jni) SWIGTYPE *CLASS "jlong"
%typemap(jtype) SWIGTYPE *CLASS "long"
%typemap(jstype) SWIGTYPE *CLASS "$javaclassname"



%include "java_arrays.i"

