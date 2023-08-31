set_directory_properties(PROPERTIES
		LABELS "no_lang;error"
)
list(APPEND test_extra_args -Wall -Fstandard)

# Add c_tests
foreach (test IN ITEMS
		c_bad_native
		c_class
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
		c_redefine_typedef
		c_spaceship
		c_varargs_neg
)
	Swig_add_test(${test} EXPECT_ERROR
			LABELS C
			EXTRA_ARGS ${test_extra_args}
	)
endforeach ()

# Add cpp_tests
foreach (test IN ITEMS
		cpp_bad_extern
		cpp_bad_global_memberptr
		cpp_class_definition
		cpp_extend_destructors
		cpp_extend_redefine
		cpp_extend_redefine_template
		cpp_extend_undefined
		cpp_extra_brackets
		cpp_extra_brackets2
		cpp_inherit
		cpp_inherit_ignored
		cpp_inline_namespace
		cpp_invalid_exponents1
		cpp_invalid_exponents2
		cpp_invalid_qualifiers
		cpp_invalid_template
		cpp_macro_locator
		cpp_missing_rparenthesis
		cpp_missing_rtemplate
		cpp_namespace_alias
		cpp_namespace_aliasnot
		cpp_namespace_aliasundef
		cpp_namespace_template_bad
		cpp_namewarn
		cpp_nested_namespace_alias
		cpp_nested_template
		cpp_no_access
		cpp_no_return_type
		cpp_nobase
		cpp_overload_const
		cpp_pp_expressions_bad
		cpp_private_inherit
		cpp_raw_string_termination
		cpp_recursive_typedef
		cpp_redefine_class
		cpp_refqualifier
		cpp_scope_bad
		cpp_shared_ptr
		cpp_template_class_repeat
		cpp_template_duplicate_names
		cpp_template_explicit_instantiation
		cpp_template_friend
		cpp_template_nargs
		cpp_template_not
		cpp_template_partial
		cpp_template_partial_specialization_defaults
		cpp_template_redefine
		cpp_template_repeat
		cpp_template_scope
		cpp_template_undef
		cpp_typemap_out_optimal_bug
		cpp_using_constructor_bad
		cpp_using_declaration_overload
		cpp_using_not
		cpp_using_rename
		cpp_using_undef
)
	Swig_add_test(${test} EXPECT_ERROR CPP
			LABELS CPP
			EXTRA_ARGS ${test_extra_args}
	)
endforeach ()

# Add doxygen_tests
foreach (test IN ITEMS
		doxygen_unclosed_tag
		doxygen_unknown_command
)
	Swig_add_test(${test} EXPECT_ERROR
			LABELS Doxygen
			EXTRA_ARGS ${test_extra_args} -doxygen
	)
endforeach ()

# Add pp_tests
foreach (test IN ITEMS
		pp_badeval
		pp_constant
		pp_defined
		pp_error_directive
		pp_expressions_bad
		pp_illegal_argument
		pp_invalid_exponents
		pp_macro_badchar
		pp_macro_defined_unterminated
		pp_macro_expansion
		pp_macro_expansion_multiline
		pp_macro_inline_unterminated
		pp_macro_missing_expression
		pp_macro_nargs
		pp_macro_redef
		pp_macro_rparen
		pp_macro_unexpected_tokens
		pp_macro_unterminated
		pp_misplaced_elif
		pp_misplaced_else
		pp_missing_enddef
		pp_missing_endif
		pp_missing_endoffile
		pp_missing_file
		pp_missing_rblock
		pp_pragma
		pp_unknowndirective
		pp_unknowndirective2
		pp_unknowndirective3
		pp_unknowndirective4
		pp_unknowndirective5
		pp_unterm_char
		pp_unterm_comment
		pp_unterm_string
		pp_unterminated_block
		pp_variable_args
)
	Swig_add_test(${test} EXPECT_ERROR
			LABELS PreProcess
			EXTRA_ARGS ${test_extra_args}
	)
endforeach ()

# Add swig_tests
foreach (test IN ITEMS
		swig_apply_nargs
		swig_command_encoder
		swig_constant_missing_semi
		swig_extend
		swig_fragment_missing
		swig_identifier
		swig_insert_bad
		swig_pythoncode_bad
		swig_pythoncode_bad2
		swig_pythoncode_bad3
		swig_typemap_copy
		swig_typemap_missing_value
		swig_typemap_old
		swig_typemap_warn
)
	Swig_add_test(${test} EXPECT_ERROR
			LABELS Swig
			EXTRA_ARGS ${test_extra_args}
	)
endforeach ()

# Add other tests
foreach (test IN ITEMS
		nomodule
)
	Swig_add_test(${test} EXPECT_ERROR
			LABELS Misc
			EXTRA_ARGS ${test_extra_args}
	)
endforeach ()
