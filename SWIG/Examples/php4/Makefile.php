all: check

check: BUILD.sh
	./BUILD.sh

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

