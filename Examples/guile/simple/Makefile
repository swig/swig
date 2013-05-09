SRCS   = example.c
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..
TOP        = ../..

check: $(TARGET)
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_embedded_run

build: $(TARGET)

$(TARGET):
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
	    sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
