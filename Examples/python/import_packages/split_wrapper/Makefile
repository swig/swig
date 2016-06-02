TOP        = ../../..
LIBS       =

subdirs = builtin vanilla builtin_split vanilla_split \
          builtin_nopy3 vanilla_nopy3 builtin_split_nopy3 vanilla_split_nopy3

check: build
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) check); \
	done

build:
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build); \
	done

static:
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static); \
	done

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	for s in $(subdirs); do \
		(cd $$s && $(MAKE) clean); \
	done
