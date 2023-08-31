function(Swig_add_test name)
	#[===[.md
	# Swig_add_test

	Internal helper for adding native swig-tests

	## Synopsis
	```cmake
	Swig_add_test(<name>
			[EXPECT_ERROR] [CPP]
			[LANGUGAGE <lang>]
			[LABELS <label1> <label2>]
			[EXTRA_ARGS <arg1> <arg2>])
	```

	## Options

	`EXPECT_ERROR`
	  Whether the test is supposed so fail. A file `<name>.stderr` must be present in the source
	  root and it should contain the

	`EXPECT_ERROR`
	  Whether to use the `-c++` flag. Will default to using C otherwise

	`LANGUAGE`
	  Language to use as `swig -<lang>` for calling the swig executable. Defaults to `python`

	`LABELS`
	  Labels to be added to the ctest. At the bare minimum it should reflect the language and
	  folder structure, but you may add any other labels you see fit for further filtering

	`EXTRA_ARGS`
	  Additional CLI arguments to be added to the CLI
	]===]
	set(ARGS_Options "EXPECT_ERROR;CPP")
	set(ARGS_OneValue "LANGUAGE")
	set(ARGS_MultiValue "LABELS;EXTRA_ARGS")
	cmake_parse_arguments(PARSE_ARGV 1 ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}")

	# Check required/optional arguments
	if (ARGC LESS 1)
		message(FATAL_ERROR
				Swig: Missing test name in Swig_add_test call)
	endif ()
	if (NOT DEFINED ARGS_LANGUAGE)
		set(ARGS_LANGUAGE python)
	endif ()
	if (ARGS_CPP)
		list(PREPEND ARGS_EXTRA_ARGS "-c++")
	endif ()

	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/${name}.i
			DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
	)
	add_test(NAME ${name}
			COMMAND $<TARGET_FILE:Swig_swig> -${ARGS_LANGUAGE} ${ARGS_EXTRA_ARGS} ${name}.i
	)
	# Basic environment so that it works in
	set_tests_properties(${name} PROPERTIES
			ENVIRONMENT "SWIG_LIB=${PROJECT_BINARY_DIR}/Lib"
			LABELS "${ARGS_LABELS}"
	)
	if (ARGS_EXPECT_ERROR)
		file(READ ${CMAKE_CURRENT_SOURCE_DIR}/${name}.stderr expected_error)
		# Escape regex expressions: Match any cmake recognized regex and escape them with a \
		# https://cmake.org/cmake/help/latest/command/string.html#regex-specification
		string(REGEX REPLACE "\\;" "\\\\;" expected_error_sanitized "${expected_error}")
		string(REGEX REPLACE "(\\^|\\$|\\.|\\(|\\)|\\[|\\]|\\*|\\+|\\?|\\|)" "\\\\\\1" expected_error_sanitized "${expected_error_sanitized}")
		# Not setting WILL_FAIL here because it overrides PASS_REGULAR_EXPRESSION
		set_tests_properties(${name} PROPERTIES
				PASS_REGULAR_EXPRESSION "${expected_error_sanitized}"
		)
	endif ()
endfunction()

# Empty extra args
set(test_extra_args)
