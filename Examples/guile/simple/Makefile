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
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean

check: $(TARGET)
	./$(TARGET) -s example.scm > /dev/null
