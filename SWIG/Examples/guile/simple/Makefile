SRCS   = example.c
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..

all: $(TARGET)

$(TARGET):
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
	    sub-all

clean::
	rm -f *_wrap* $(TARGET) *~ .~* core

check: $(TARGET)
	./$(TARGET) -s example.scm > /dev/null
