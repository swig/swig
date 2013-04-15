SRCS   = port.c
TARGET = port
IFILE  = port.i
MKDIR  = ..

check: build

build:
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		MODULE=$(MODULE)		\
	  sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
