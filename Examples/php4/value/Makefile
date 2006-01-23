
SWIGFLAGS   = -noproxy

C_SOURCES   = example.c 
CXX_SOURCES = 

SWIG = ../../../preinst-swig

all: check

example_wrap.c: example.i
	$(SWIG) -php4 $(SWIGFLAGS) example.i

OBJS= example_wrap.o $(C_SOURCES:.c=.o) $(CXX_SOURCES:.cxx=.o)

PROG=php_example.so

PHP_INC=`php-config --includes`

CFLAGS  = -fpic
LDFLAGS = -shared

$(PROG): $(OBJS)
	$(CXX) $(LDFLAGS) $(OBJS) -o $(PROG) $(EXTRA_LIB)

%.o: %.cpp
	$(CXX) $(PHP_INC) $(CFLAGS) -c $<
%.o: %.cxx
	$(CXX) $(PHP_INC) $(CFLAGS) -c $<
%.o: %.c
	$(CC) $(PHP_INC) $(CFLAGS) -c $<

check: $(PROG)
	@php -d extension_dir=. runme.php4

clean:
	rm -f example_wrap.* *.o *~ *.so core example.php php_example.h
