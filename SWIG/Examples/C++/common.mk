TOP =../..

all:: $(TARGETS)

include $(TOP)/Makefile

SWIG = $(TOP)/../swig

ISRCS = $(notdir $(INTERFACE:.i=_wrap.c))

$(JAR): $(JAR_FILES)
	rm -rf class
	mkdir class
	javac -d class $(JAR_FILES)
	cd class && jar cvf ../$@ *

INCLUDE = -I$(TOP)/../Lib -I../class -I../typemaps  -I$(TOP)/../Lib

check:: all
	bad_status="" ; \
	for i in $(TESTS); do \
	  LD_LIBRARY_PATH=. PYTHONPATH=. CLASSPATH=./$(JAR) ; \
	  ( $(PYTHON) $$i && echo "$$i: PASSED" ) || echo "$$i: FAILED"; \
	done

.PHONY: check

# common.mk ends here
