ifeq (,$(PY3))
  PYTHON_INCLUDE= $(DEFS) -I/usr/include/python2.6 -I/usr/lib/python2.6/config
  PYTHON_LIB    = 
  PYTHON        = python
  PYSCRIPT = runme.py
else
  PYTHON_INCLUDE= $(DEFS) -I/home/szager/include/python3.1
  PYTHON_LIB    = 
  PYTHON        = python3
  PYSCRIPT = runme3.py
endif

SUBDIRS := constructor func deep_hierarchy

default : all

.PHONY : $(SUBDIRS) all clean

all : $(SUBDIRS)
	@for subdir in $(SUBDIRS); do \
		echo Running $$subdir test... ; \
		echo -------------------------------------------------------------------------------- ; \
		cd $$subdir; \
		env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH PYTHONPATH=$(srcdir):$$PYTHONPATH $(PYTHON) $(PYSCRIPT); \
		cd ..; \
	done

$(SUBDIRS) :
	$(MAKE) -C $@
	@echo Running $$subdir test...
	@echo --------------------------------------------------------------------------------
	cd $@ && env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH PYTHONPATH=$(srcdir):$$PYTHONPATH $(PYTHON) $(PYSCRIPT)

%-clean :
	$(MAKE) -s -C $* clean

$(SUBDIRS:%=%-check) :
	$(MAKE) -C $* check

clean : $(SUBDIRS:%=%-clean)
