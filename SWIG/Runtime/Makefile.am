## Process this file with automake to produce Makefile.in

SWIGLIB                = @top_srcdir@/Lib
SWIG_TYPECHECK         = $(SWIGLIB)/common.swg
RELEASE_SUFFIX_LIBTOOL = @release_suffix_libtool@

# Additional clean
clean-local:
	rm -f *.c

# List of runtime libraries to be built
lib_LTLIBRARIES =

if !SKIP_TCL
lib_LTLIBRARIES += libswigtcl8.la
endif
if !SKIP_PERL5
lib_LTLIBRARIES += libswigpl.la
endif
if !SKIP_PYTHON
lib_LTLIBRARIES += libswigpy.la
endif
if !SKIP_GUILE
lib_LTLIBRARIES += libswigguile.la
endif
if !SKIP_GUILESCM
lib_LTLIBRARIES += libswigguilescm.la
endif
if !SKIP_RUBY
lib_LTLIBRARIES += libswigrb.la
endif
if !SKIP_PHP4
lib_LTLIBRARIES += libswigphp4.la
endif
if !SKIP_PIKE
lib_LTLIBRARIES += libswigpike.la
endif
if !SKIP_CHICKEN
lib_LTLIBRARIES += libswigchicken.la
endif

# ----------------------------------------------------------------------
# Tcl run-time library
# ----------------------------------------------------------------------

TCL_INCLUDE = @TCLINCLUDE@
TCL_RUNTIME = $(SWIGLIB)/tcl/swigtcl8.swg
TCL_PRECOMMON = $(SWIGLIB)/tcl/precommon.swg
TCL_DLNK    = @TCLDYNAMICLINKING@

libswigtcl8_la_SOURCES  = libtcl8.c
libswigtcl8_la_LDFLAGS  = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(TCL_DLNK)
libswigtcl8_la_CFLAGS   = $(TCL_INCLUDE)

libtcl8.c: $(TCL_PRECOMMON) $(SWIG_TYPECHECK) $(TCL_RUNTIME)
	../preinst-swig -tcl -runtime -o libtcl8.c swigrun.i

# ----------------------------------------------------------------------
# Perl run-time library
# ----------------------------------------------------------------------

PERL5_INCLUDE = -I@PERL5EXT@
PERL5_RUNTIME = $(SWIGLIB)/perl5/perlrun.swg
PERL5_PRECOMMON = $(SWIGLIB)/perl5/precommon.swg
PERL5_DLNK    = @PERL5DYNAMICLINKING@
PERL5_CCFLAGS = @PERL5CCFLAGS@

libswigpl_la_SOURCES    = libpl.c
libswigpl_la_LDFLAGS    = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(PERL5_DLNK)
libswigpl_la_CFLAGS     = $(PERL5_INCLUDE) -Dbool=char -Dexplicit=$(PERL5_CCFLAGS)

libpl.c: $(PERL5_PRECOMMON) $(SWIG_TYPECHECK) $(PERL5_RUNTIME)
	../preinst-swig -perl5 -runtime -o libpl.c swigrun.i	

# ----------------------------------------------------------------------
# Python run-time library
# ----------------------------------------------------------------------

PYTHON_INCLUDE = -DHAVE_CONFIG_H @PYINCLUDE@
PYTHON_RUNTIME = $(SWIGLIB)/python/pyrun.swg
PYTHON_PRECOMMON = $(SWIGLIB)/python/precommon.swg
PYTHON_DLNK    = @PYTHONDYNAMICLINKING@

libswigpy_la_SOURCES    = libpy.c
libswigpy_la_LDFLAGS    = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(PYTHON_DLNK)
libswigpy_la_CFLAGS     = $(PYTHON_INCLUDE)

libpy.c: $(PYTHON_PRECOMMON) $(SWIG_TYPECHECK) $(PYTHON_RUNTIME)
	../preinst-swig -python -runtime -o libpy.c swigrun.i	

# ----------------------------------------------------------------------
# Guile run-time library
# ----------------------------------------------------------------------

GUILE_INCLUDE = @GUILEINCLUDE@
GUILE_GH_RUNTIME = $(SWIGLIB)/guile/guile_gh_run.swg
GUILE_SCM_RUNTIME = $(SWIGLIB)/guile/guile_scm_run.swg
GUILE_SCM_PRECOMMON = $(SWIGLIB)/guile/precommon.swg
GUILE_DLNK    = $(GUILELINK)

libswigguile_la_SOURCES = libguile_gh.c
libswigguile_la_LDFLAGS = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(GUILE_DLNK)
libswigguile_la_CFLAGS  = -DSWIG_GLOBAL $(GUILE_INCLUDE)

libguile_gh.c: $(GUILE_GH_RUNTIME)
	../preinst-swig -guile -gh -Linkage passive -runtime -o libguile_gh.c swigrun.i

libswigguilescm_la_SOURCES = libguile_scm.c
libswigguilescm_la_LDFLAGS = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(GUILE_DLNK)
libswigguilescm_la_CFLAGS = -DSWIG_GLOBAL $(GUILE_INCLUDE)

libguile_scm.c: $(GUILE_SCM_PRECOMMON) $(SWIG_TYPECHECK) $(GUILE_SCM_RUNTIME) $(SWIGLIB)/guile/swigrun.i
	../preinst-swig -guile -scm -Linkage module -package Swig -runtime -o libguile_scm.c swigrun.i

guileschemedir = $(datadir)/guile/Swig
guilescheme_DATA = ../Lib/guile/common.scm

# ----------------------------------------------------------------------
# Ruby run-time library
# ----------------------------------------------------------------------

RUBY_INCLUDE = @RUBYINCLUDE@
RUBY_RUNTIME = $(SWIGLIB)/ruby/rubyhead.swg $(SWIGLIB)/ruby/rubydef.swg
RUBY_PRECOMMON = $(SWIGLIB)/ruby/precommon.swg
RUBY_DLNK    = @RUBYDYNAMICLINKING@
RUBY_CFLAGS  = @RUBYCCDLFLAGS@ -DHAVE_CONFIG_H

libswigrb_la_SOURCES    = librb.c
libswigrb_la_LDFLAGS    = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(RUBY_DLNK)
libswigrb_la_CFLAGS     = $(RUBY_INCLUDE) $(RUBY_CFLAGS)

librb.c: $(RUBY_PRECOMMON) $(SWIG_TYPECHECK) $(RUBY_RUNTIME)
	../preinst-swig -ruby -runtime -o librb.c swigrun.i	

# ----------------------------------------------------------------------
# PHP4 run-time library
# ----------------------------------------------------------------------

PHP4_INCLUDE = @PHP4INC@
PHP4_RUNTIME = $(SWIGLIB)/php4/php4run.swg
PHP4_PRECOMMON = $(SWIGLIB)/php4/precommon.swg
PHP4_DLNK    = 

libswigphp4_la_SOURCES  = libphp4.c
libswigphp4_la_LDFLAGS  = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(PHP4_DLNK)
libswigphp4_la_CFLAGS   = $(PHP4_INCLUDE)

libphp4.c: $(PHP4_PRECOMMON) $(SWIG_TYPECHECK) $(PHP4_RUNTIME)
	../preinst-swig -php -runtime -o libphp4.c swigrun.i	

# ----------------------------------------------------------------------
# Pike run-time library
# ----------------------------------------------------------------------

PIKE_INCLUDE = -DHAVE_CONFIG_H @PIKEINCLUDE@
PIKE_RUNTIME = $(SWIGLIB)/pike/pikerun.swg
PIKE_PRECOMMON = $(SWIGLIB)/pike/precommon.swg
PIKE_DLNK    = 

libswigpike_la_SOURCES  = libpike.c
libswigpike_la_LDFLAGS  = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(PIKE_DLNK)
libswigpike_la_CFLAGS   = -DSWIG_GLOBAL $(PIKE_INCLUDE)

libpike.c: $(PIKE_PRECOMMON) $(SWIG_TYPECHECK) $(PIKE_RUNTIME)
	cat $(PIKE_PRECOMMON) $(SWIG_TYPECHECK) $(PIKE_RUNTIME) > libpike.c

# ----------------------------------------------------------------------
# CHICKEN run-time library
# ----------------------------------------------------------------------

CHICKENOPTS     = @CHICKENOPTS@
CHICKEN_RUNTIME = $(SWIGLIB)/chicken/chickenrun.swg
CHICKEN_PRECOMMON = $(SWIGLIB)/chicken/precommon.swg
CHICKEN_DLNK    = @CHICKENSHAREDLIB@

libswigchicken_la_SOURCES = libchicken.c
libswigchicken_la_LDFLAGS = @LIBTOOL_NO_UNDEFINED@ $(RELEASE_SUFFIX_LIBTOOL) $(CHICKEN_DLNK)
libswigchicken_la_CFLAGS  = $(CHICKEN_INCLUDE)

libchicken.c: $(CHICKEN_PRECOMMON) $(SWIG_TYPECHECK) $(CHICKEN_RUNTIME)
	../preinst-swig -chicken -runtime -o libchicken.c swigrun.i	

# ----------------------------------------------------------------------
# The following do not use Libtool
# There are no install and uninstall targets. These could be implemented
# with Automake's install-exec-local and uninstall-local targets.
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# MzScheme run-time library
# ----------------------------------------------------------------------

MZSCHEME_RUNTIME = $(SWIGLIB)/mzscheme/precommon.swg $(SWIG_TYPECHECK) $(SWIGLIB)/mzscheme/mzrun.swg
MZC = @MZC@
SO = @MZSCHEME_SO@
RELEASESUFFIX   = @release_suffix@

# Add in non Libtool targets
if !SKIP_MZSCHEME
all-local: .libs/libswigmz$(RELEASESUFFIX)$(SO)
else
all-local:
endif

libmz.c: $(MZSCHEME_RUNTIME)
	../preinst-swig -mzscheme -runtime -noinit -o libmz.c swigrun.i	

.libs/libswigmz$(RELEASESUFFIX)$(SO): libmz.c
	$(MZC) ++ccf "-DSWIG_GLOBAL" --cc libmz.c
	if [ ! -d .libs ] ; then mkdir .libs; fi
	$(MZC) --ld .libs/libswigmz$(RELEASESUFFIX)$(SO) libmz.o

