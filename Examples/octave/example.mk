# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = swigexample
INTERFACE  = example.i

BUILDCMD = \
	$(MAKE) -f $(TOP)/Makefile \
	SRCDIR='$(SRCDIR)' \
	SWIG='$(SWIG)' \
	INTERFACE='$(INTERFACE)'

ifneq (,$(SRCS))
  BUILDCMD += SRCS='$(SRCS)'
  BUILDTARGET = octave
else
  BUILDCMD += CXXSRCS='$(CXXSRCS)'
  BUILDTARGET = octave_cpp
endif

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' octave_run

build:
	$(BUILDCMD) SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' $(BUILDTARGET)

ifneq (,$(TARGET2)$(SWIGOPT2))

check: build2

build2:
	$(BUILDCMD) SWIGOPT='$(SWIGOPT2)' TARGET='$(TARGET2)' $(BUILDTARGET)

endif

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' octave_clean
