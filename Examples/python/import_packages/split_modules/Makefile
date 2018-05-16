TOP        = ../../..
LIBS       =

subdirs = vanilla vanilla_split


check: build
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) check) || exit 1; \
	done

build:
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build) || exit 1; \
	done

static:
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static) || exit 1; \
	done

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) clean) || exit 1; \
	done
