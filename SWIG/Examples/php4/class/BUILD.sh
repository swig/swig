#! /bin/sh -e

${SWIG:=swig}  -php4 -phpfull -c++ -noproxy -withcxx example.cxx example.i
phpize && ./configure && make clean && make
