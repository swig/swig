LANGUAGE     = ocaml
VARIANT      = _static
SCRIPTSUFFIX = _runme.ml

C_TEST_CASES = 

run_testcase = \
	if [ -f $*\_runme.ml ] ; then \
		(ocamlc -c $*\_runme.ml ; \
		ocamlc -custom -o runme $*\.cmo $*\_runme.cmo ; \
		./runme) \
	fi ; 

include ../common.mk

%.cpptest:
	$(setup) \
	($(swig_and_compile_cpp); ); \
	$(run_testcase) \

%.ctest:
	$(setup) \
	($(swig_and_compile_c); ); \
	$(run_testcase) \

%.multicpptest:
	$(setup) \
	($(swig_and_compile_multi_cpp); ); \
	$(run_testcase)

%.clean:
	@rm -f *_wrap* *.o *~ ~* core `find . -name \*.ml\* | grep -v runme` \
		*.cmi *.cmo
