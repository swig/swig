CRUD=acinclude.m4 aclocal.m4 config.cache config.h config.h.in config.log \
     config.m4 config.nice config.status config.sub configure configure.in \
     config_vars.mk config.guess CREDITS dynlib.m4 *.so *.lo *.o *.slo \
     install-sh libs.mk libtool ltmain.sh Makefile Makefile.in missing \
     mkinstalldirs php_example.h php_example.la *_wrap.c* example.php \
     build modules .deps .libs conftest conftest.c

all: check

check: BUILD.sh
	./BUILD.sh
#	SWIG=$(SWIG) ./BUILD.sh

# This one is fun!  How do we know what shouldn't be there?
clean:
	rm -fr $(CRUD)

BUILD.sh:
	echo "-------------------------------------------------"
	echo `pwd`"/BUILD.sh missing!"
	echo "I need BUILD.sh file to show me how to invoke swig"
	echo "It usually looks like this:"
	echo
	echo "swig -php -phpfull -c++ <extra options> example.i"
	echo "# and then the rest is always the same..."
	echo "phpize && ./configure && make && make install"
	echo
	echo 
	exit 1

