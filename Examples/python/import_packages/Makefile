TOP        = ../..
SWIGOPT    =
LIBS       =

import_packages_subdirs = \
	same_modnames1 \
	same_modnames2 \
	from_init1 \
	from_init2 \
	from_init3 \
	module_is_init \
	relativeimport1 \
	relativeimport2 \
	relativeimport3 \
	split_modules \
	namespace_pkg \


check: build
	if test "x$(SRCDIR)" != x; then \
		for file in `cd $(SRCDIR) && find . -type f -name "*.py"`; do \
			mkdir -p `dirname $$file`; \
			cp "${SRCDIR}$$file" "$$file" || exit 1; \
		done; \
	fi
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) check) || exit 1; \
	done

build:
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build) || exit 1; \
	done

static:
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static) || exit 1; \
	done

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	if test "x$(SRCDIR)" != x; then \
		for file in `cd $(SRCDIR) && find . -type f -name "*.py"`; do \
			rm -f "$$file" || exit 1; \
		done; \
	fi
	for s in $(import_packages_subdirs); do \
		(cd $$s && $(MAKE) clean) || exit 1; \
	done
