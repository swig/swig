CC     = gcc
SRCS   = port.c
TARGET = port
IFILE  = port.i
MKDIR  = ..


all::
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		CC=$(CC)			\
		MODULE=$(MODULE)		\
	  sub-all

clean::
	rm -f $(TARGET) *_wrap* *~ .~* core test.out

check: all
