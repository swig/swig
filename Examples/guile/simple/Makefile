SRCS   = example.c
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..

check: $(TARGET)
	./$(TARGET) -s example.scm

build: $(TARGET)

$(TARGET):
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
	    sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
