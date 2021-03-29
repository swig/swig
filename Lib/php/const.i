/* -----------------------------------------------------------------------------
 * const.i
 *
 * Typemaps for constants
 * ----------------------------------------------------------------------------- */
%typemap(classconsttab) int,
                        unsigned int,
                        short,
                        unsigned short,
                        long,
                        unsigned long,
                        unsigned char,
                        signed char,
                        enum SWIGTYPE
  "zend_declare_class_constant_long(SWIGTYPE_$class_ce, \"$const_name\", sizeof(\"$const_name\") - 1, ($1_type)$value);";

 %typemap(classconsttab) bool
  "zend_declare_class_constant_bool(SWIGTYPE_$class_ce, \"$const_name\", sizeof(\"$const_name\") - 1, ($1_type)$value);";

 %typemap(classconsttab) float,
                         double
  "zend_declare_class_constant_double(SWIGTYPE_$class_ce, \"$const_name\", sizeof(\"$const_name\") - 1, $value);";

 %typemap(classconsttab) char,
                         string
  "zend_declare_class_constant_string(SWIGTYPE_$class_ce, \"$const_name\", sizeof(\"$const_name\") - 1, \"$value\");";

%typemap(consttab) int,
                   unsigned int,
                   short,
                   unsigned short,
                   long,
                   unsigned long,
                   unsigned char,
                   signed char,
                   enum SWIGTYPE
  "SWIG_LONG_CONSTANT($symname, ($1_type)$value);";

%typemap(consttab) bool
  "SWIG_BOOL_CONSTANT($symname, ($1_type)$value);";

%typemap(consttab) float,
                   double
  "SWIG_DOUBLE_CONSTANT($symname, $value);";

%typemap(consttab) char
  "SWIG_CHAR_CONSTANT($symname, $value);";

%typemap(consttab) char *,
                   const char *,
                   char [],
                   const char []
  "SWIG_STRING_CONSTANT($symname, $value);";

%typemap(consttab) SWIGTYPE *,
                   SWIGTYPE &,
                   SWIGTYPE &&,
                   SWIGTYPE [] {
  zend_constant c;
  SWIG_SetPointerZval(&c.value, (void*)$value, $1_descriptor, 0);
  zval_copy_ctor(&c.value);
  c.name = zend_string_init("$symname", sizeof("$symname") - 1, 0);
  SWIG_ZEND_CONSTANT_SET_FLAGS(&c, CONST_CS, module_number);
  zend_register_constant(&c);
}

/* Handled as a global variable. */
%typemap(consttab) SWIGTYPE (CLASS::*) "";
