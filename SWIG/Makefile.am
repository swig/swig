include $(top_srcdir)/Makefile.common

EXTRA_DIST = Makefile.common LICENSE Lib Doc Examples

SUBDIRS = Source 

all-local:
	cp $(top_builddir)/Source/SWIG1.1/swig swig

experiment: all
	cp $(top_builddir)/Source/Experiment/experiment swig

dist-hook:
	find $(distdir) -depth -name CVS -print | xargs rm -fr 

SWIG_LIB = $(prefix)/lib/swig1.3

install-data-local:
	@for i in $(SWIG_LIB) ; \
	do \
	  if [ ! -d $$i ] ; then \
	         mkdir $$i; \
                 echo "Making directory $$i"; \
                 chmod 755 $$i;\
                 else true; \
             fi; \
            done;
	@echo "Installing the SWIG library"
#	cd $(SWIG_LIB); rm -rf *
	@for i in $(SWIG_LIB)/tcl $(SWIG_LIB)/perl5 $(SWIG_LIB)/python $(SWIG_LIB)/guile ; \
	do \
	  if [ ! -d $$i ] ; then \
	         mkdir $$i; \
                 echo "Making directory $$i"; \
                 chmod 755 $$i;\
                 else true; \
             fi; \
            done;
	@cd $(top_srcdir)/Lib; for i in *.i *.swg; \
	    do \
	    echo "Installing Lib/$$i"; \
            $(INSTALL_DATA) $$i $(SWIG_LIB)/$$i; \
	    done;
	@cd $(top_srcdir)/Lib/tcl; for i in *.i *.swg; \
	    do \
	    echo "Installing Lib/tcl/$$i"; \
            $(INSTALL_DATA) $$i $(SWIG_LIB)/tcl/$$i; \
	    done;
	@cd $(top_srcdir)/Lib/perl5; for i in *.i *.swg Makefile.pl; \
	    do \
	    echo "Installing Lib/perl5/$$i"; \
            $(INSTALL_DATA) $$i $(SWIG_LIB)/perl5/$$i; \
	    done;
	@cd $(top_srcdir)/Lib/python; for i in *.i *.swg; \
	    do \
	    echo "Installing Lib/python/$$i"; \
            $(INSTALL_DATA) $$i $(SWIG_LIB)/python/$$i; \
	    done;
	@cd $(top_srcdir)/Lib/guile; for i in *.i *.swg; \
	    do \
	    echo "Installing Lib/guile/$$i"; \
            $(INSTALL_DATA) $$i $(SWIG_LIB)/guile/$$i; \
	    done;
