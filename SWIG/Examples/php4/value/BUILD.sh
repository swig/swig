#! /bin/sh -e

${SWIG:=swig} -php4 -phpfull -noproxy -withc example.c example.i
phpize && ./configure && make clean && make
