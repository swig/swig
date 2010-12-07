#!/bin/sh
echo "---------------------------------------"
echo "Testing SWIG error and warning messages"
echo "---------------------------------------"

SWIG='../../../preinst-swig'

# Files run in C mode
CFILES='
c_bad_name
c_bad_native
c_class
c_default_error
c_deprecated
c_empty_char
c_enum_badvalue
c_extra_rblock
c_extra_rbrace
c_extra_unsigned
c_insert_missing
c_long_short
c_missing_rbrace
c_missing_semi
c_redefine
c_varargs
c_varargs_neg
nomodule
pp_badeval
pp_constant
pp_defined
pp_deprecated
pp_illegal_argument
pp_macro_args
pp_macro_badchar
pp_macro_defined_unterminated
pp_macro_expansion
pp_macro_expansion_multiline
pp_macro_inline_unterminated
pp_macro_nargs
pp_macro_redef
pp_macro_rparen
pp_macro_unterminated
pp_misplaced_elif
pp_misplaced_else
pp_missing_enddef
pp_missing_endif
pp_missing_file
pp_missing_rblock
pp_pragma
pp_unterm_char
pp_unterm_comment
pp_unterm_string
pp_variable_args
swig_apply_nargs
swig_identifier
swig_insert_bad
swig_typemap_copy
swig_typemap_old
'

# Files run in C++ mode
CPPFILES='
cpp_bad_extern
cpp_extend_redefine
cpp_extend_undefined
cpp_inline_namespace
cpp_inherit
cpp_macro_locator
cpp_missing_rtemplate
cpp_namespace_alias
cpp_namespace_aliasnot
cpp_namespace_aliasundef
cpp_nested
cpp_no_access
cpp_nobase
cpp_overload
cpp_private_defvalue
cpp_private_inherit
cpp_template_argname
cpp_template_nargs
cpp_template_not
cpp_template_partial
cpp_template_repeat
cpp_template_undef
cpp_using_not
cpp_using_undef
'

LOGFILE='test.log'
SWIGOPT=$*

rm -f ${LOGFILE}

echo "SWIG error and warning test. opts=${SWIGOPT}" >> ${LOGFILE}
echo "-----------------------------------------------------------" >> ${LOGFILE}

for i in ${CFILES}; do 
   echo "    Testing : ${i}.i"; 
   echo "" >> ${LOGFILE};
   echo ":::::::::::::::::::::::::::::::: ${i}.i :::::::::::::::::::::::::::::::::::" >> ${LOGFILE};
   ${SWIG} -Wall ${SWIGOPT} ${i}.i >>${LOGFILE} 2>&1
done

for i in ${CPPFILES}; do 
   echo "    Testing : ${i}.i"; 
   echo "" >> ${LOGFILE}
   echo ":::::::::::::::::::::::::::::::: ${i}.i :::::::::::::::::::::::::::::::::::" >> ${LOGFILE};
   ${SWIG} -Wall -c++ ${SWIGOPT} ${i}.i >>${LOGFILE} 2>&1
done

echo ""
echo "Results written to '${LOGFILE}'"


