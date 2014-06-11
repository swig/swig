TOP        = ../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =
PY3        =

import_packages_subdirs = \
	same_modnames1 \
	same_modnames2 \
	from_init1 \
	from_init2 \
	from_init3 \
	relativeimport1 \
	relativeimport1

check: build
	if test "x$(SRCDIR)" != x; then \
		for file in `cd $(SRCDIR) && find . -type f -name __init__.py`; do \
			cp "${SRCDIR}$$file" "$$file" || exit 1; \
		done; \
	fi; \
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) check); \
	done

build:
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build); \
	done

static:
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static); \
	done

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	if test "x$(SRCDIR)" != x; then \
		for file in `cd $(SRCDIR) && find . -type f -name __init__.py`; do \
			rm -f "$$file" || exit 1; \
		done; \
	fi; \
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) clean); \
	done
