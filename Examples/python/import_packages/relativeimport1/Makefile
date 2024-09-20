TOP        = ../../..
LIBS       =

ifneq (,$(PY2))
  PKG1DIR  = "py2"
else
  PKG1DIR  = "py3"
endif

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	$(MAKE) -C $(PKG1DIR) SWIGOPT='$(SWIGOPT) -relativeimport' LIBS='$(LIBS)' build

static:
	$(MAKE) -C $(PKG1DIR) SWIGOPT='$(SWIGOPT) -relativeimport' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	$(MAKE) -C py2 clean
	$(MAKE) -C py3 clean
