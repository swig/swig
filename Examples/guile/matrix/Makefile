SRCS   = matrix.c vector.c
TARGET = matrix
IFILE  = package.i
MKDIR  = ..

check: build
	./$(TARGET) -e do-test -s matrix.scm

build:
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		MODULE=$(MODULE)		\
		LIBS="-lm"			\
	  sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
