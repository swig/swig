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
if !SKIP_RUBY
lib_LTLIBRARIES += libswigrb.la
endif
if !SKIP_PHP4
lib_LTLIBRARIES += libswigphp4.la
endif
if !SKIP_OCAML
lib_LTLIBRARIES += libswigocaml.la
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
TCL_DLNK    = @TCLDYNAMICLINKING@

libswigtcl8_la_SOURCES  = libtcl8.c
libswigtcl8_la_LDFLAGS  = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(TCL_DLNK)
libswigtcl8_la_CFLAGS   = -DSWIG_GLOBAL $(TCL_INCLUDE)

libtcl8.c: $(SWIG_TYPECHECK) $(TCL_RUNTIME)
	cat $(SWIG_TYPECHECK) $(TCL_RUNTIME) >> libtcl8.c

# ----------------------------------------------------------------------
# Perl run-time library
# ----------------------------------------------------------------------

PERL5_INCLUDE = -I@PERL5EXT@
PERL5_RUNTIME = $(SWIGLIB)/perl5/perlrun.swg
PERL5_DLNK    = @PERL5DYNAMICLINKING@
PERL5_CCFLAGS = @PERL5CCFLAGS@

libswigpl_la_SOURCES    = libpl.c
libswigpl_la_LDFLAGS    = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(PERL5_DLNK)
libswigpl_la_CFLAGS     = -DSWIG_GLOBAL $(PERL5_INCLUDE) -Dbool=char -Dexplicit=$(PERL5_CCFLAGS)

libpl.c: $(SWIG_TYPECHECK) $(PERL5_RUNTIME)
	cat $(SWIG_TYPECHECK) $(PERL5_RUNTIME) >> libpl.c

# ----------------------------------------------------------------------
# Python run-time library
# ----------------------------------------------------------------------

PYTHON_INCLUDE = -DHAVE_CONFIG_H @PYINCLUDE@
PYTHON_RUNTIME = $(SWIGLIB)/python/pyrun.swg
PYTHON_DLNK    = @PYTHONDYNAMICLINKING@

libswigpy_la_SOURCES    = libpy.c
libswigpy_la_LDFLAGS    = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(PYTHON_DLNK)
libswigpy_la_CFLAGS     = -DSWIG_GLOBAL $(PYTHON_INCLUDE)

libpy.c: $(SWIG_TYPECHECK) $(PYTHON_RUNTIME)
	cat $(SWIG_TYPECHECK) $(PYTHON_RUNTIME) >> libpy.c

# ----------------------------------------------------------------------
# Guile run-time library
# ----------------------------------------------------------------------

GUILE_INCLUDE = @GUILEINCLUDE@
GUILE_RUNTIME = $(SWIGLIB)/guile/guiledec.swg $(SWIGLIB)/guile/guile.swg
GUILE_DLNK    = 

libswigguile_la_SOURCES = libguile.c
libswigguile_la_LDFLAGS = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(GUILE_DLNK)
libswigguile_la_CFLAGS  = -DSWIG_GLOBAL $(GUILE_INCLUDE)

libguile.c: $(GUILE_RUNTIME)
	cat $(GUILE_RUNTIME) >> libguile.c

# ----------------------------------------------------------------------
# Ruby run-time library
# ----------------------------------------------------------------------

RUBY_INCLUDE = @RUBYINCLUDE@
RUBY_RUNTIME = $(SWIGLIB)/ruby/rubyhead.swg $(SWIGLIB)/ruby/rubydef.swg
RUBY_DLNK    = @RUBYDYNAMICLINKING@
RUBY_CFLAGS  = @RUBYCCDLFLAGS@ -DHAVE_CONFIG_H

libswigrb_la_SOURCES    = librb.c
libswigrb_la_LDFLAGS    = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(RUBY_DLNK)
libswigrb_la_CFLAGS     = -DSWIG_GLOBAL $(RUBY_INCLUDE) $(RUBY_CFLAGS)

librb.c: $(SWIG_TYPECHECK) $(RUBY_RUNTIME)
	cat $(SWIG_TYPECHECK) $(RUBY_RUNTIME) > librb.c

# ----------------------------------------------------------------------
# PHP4 run-time library
# ----------------------------------------------------------------------

PHP4_INCLUDE = @PHP4INC@
PHP4_RUNTIME = $(SWIGLIB)/php4/php4run.swg
PHP4_DLNK    = 

libswigphp4_la_SOURCES  = libphp4.c
libswigphp4_la_LDFLAGS  = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(PHP4_DLNK)
libswigphp4_la_CFLAGS   = -DSWIG_GLOBAL $(PHP4_INCLUDE)

libphp4.c: $(SWIG_TYPECHECK) $(PHP4_RUNTIME)
	cat $(SWIG_TYPECHECK) $(PHP4_RUNTIME) >> libphp4.c

# ----------------------------------------------------------------------
# Ocaml run-time library
# ----------------------------------------------------------------------

OCAML_INCLUDE = @OCAMLINC@ -I$(SWIGLIB)/ocaml
OCAML_RUNTIME = $(SWIGLIB)/ocaml/libswigocaml.swg
OCAML_DLNK    = 

libswigocaml_la_SOURCES = libocaml.c
libswigocaml_la_LDFLAGS = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(OCAML_DLNK)
libswigocaml_la_CFLAGS  = -DSWIG_GLOBAL $(OCAML_INCLUDE)

libocaml.c: $(OCAML_RUNTIME)
	cat $(OCAML_RUNTIME) >> libocaml.c

# ----------------------------------------------------------------------
# Pike run-time library
# ----------------------------------------------------------------------

PIKE_INCLUDE = -DHAVE_CONFIG_H @PIKEINCLUDE@
PIKE_RUNTIME = $(SWIGLIB)/pike/pikerun.swg
PIKE_DLNK    = 

libswigpike_la_SOURCES  = libpike.c
libswigpike_la_LDFLAGS  = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(PIKE_DLNK)
libswigpike_la_CFLAGS   = -DSWIG_GLOBAL $(PIKE_INCLUDE)

libpike.c: $(SWIG_TYPECHECK) $(PIKE_RUNTIME)
	cat $(SWIG_TYPECHECK) $(PIKE_RUNTIME) >> libpike.c

# ----------------------------------------------------------------------
# CHICKEN run-time library
# ----------------------------------------------------------------------

CHICKENOPTS     = @CHICKENOPTS@
CHICKEN_RUNTIME = $(SWIGLIB)/chicken/chickenrun.swg
CHICKEN_DLNK    = 

libswigchicken_la_SOURCES = libchicken.c
libswigchicken_la_LDFLAGS = -no-undefined $(RELEASE_SUFFIX_LIBTOOL) $(CHICKEN_DLNK)
libswigchicken_la_CFLAGS  = -DSWIG_GLOBAL $(CHICKEN_INCLUDE)

libchicken.c: $(SWIG_TYPECHECK) $(CHICKEN_RUNTIME)
	cat $(SWIG_TYPECHECK) $(CHICKEN_RUNTIME) >> libchicken.c



# ----------------------------------------------------------------------
# The following do not use Libtool
# There are no install and uninstall targets. These could be implemented
# with Automake's install-exec-local and uninstall-local targets.
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# MzScheme run-time library
# ----------------------------------------------------------------------

MZSCHEME_RUNTIME = $(SWIGLIB)/mzscheme/mzschemedec.swg $(SWIGLIB)/mzscheme/mzscheme.swg
MZC = @MZC@
SO = @SO@
RELEASESUFFIX   = @release_suffix@

# Add in non Libtool targets
if !SKIP_MZSCHEME
all-local: .libs/libswigmz$(RELEASESUFFIX)$(SO)
endif

.libs/libswigmz$(RELEASESUFFIX)$(SO): $(MZSCHEME_RUNTIME)
	rm -f libmz.c
	cat $(MZSCHEME_RUNTIME) >> libmz.c
	$(MZC) ++ccf "-DSWIG_GLOBAL" --cc libmz.c
	if [ ! -d .libs ] ; then mkdir .libs; fi
	$(MZC) --ld .libs/libswigmz$(RELEASESUFFIX)$(SO) libmz.o

