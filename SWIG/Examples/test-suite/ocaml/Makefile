LANGUAGE     = ocaml
VARIANT      = _static
SCRIPTSUFFIX = _runme.ml

C_TEST_CASES = 

run_testcase = \
	if [ -f $*\_runme.ml ] ; then \
		(ocamlc -c $*\_runme.ml ; \
		ocamlc -custom -g -cc '$(CXX)' -o runme $*\.cmo $*\_runme.cmo $*\_wrap.o ; \
		./runme) ; \
	fi ; 

check_quant:
	cat /dev/null > testing
	cat /dev/null > success
	cat /dev/null > results
	$(MAKE) check
	echo "Failed:" >> results
	for element in `cat testing` ; do \
		if grep $$element success >/dev/null 2>/dev/null ; then \
			: ; \
		else \
			echo $$element >> results ; \
		fi ; \
	done
	echo "Success:" >> results
	cat success >> results

include ../common.mk

%.cpptest:
	echo $@ >> testing
	$(setup) \
	($(swig_and_compile_cpp); ) ; \
	$(run_testcase) \
	if [ -f $(@:%.cpptest=%_wrap.o) ] ; then \
		echo $@ >> success ; \
	fi

%.ctest:
	echo $@ >> testing
	$(setup) \
	($(swig_and_compile_c); ) ; \
	$(run_testcase) \
	if [ -f $(@:%.ctest=%_wrap.o) ] ; then \
		echo $@ >> success ; \
	fi

%.multicpptest:
	echo $@ >> testing
	$(setup) \
	($(swig_and_compile_multi_cpp); ) ; \
	$(run_testcase) \
	if [ -f $(@:%.multicpptest=%_a_wrap.o) ] ; then \
		echo $@ >> success ; \
	fi

%.clean:
	@rm -f $*.ml $*.mli;

clean:
	$(MAKE) -f $(TOP)/Makefile ocaml_clean

