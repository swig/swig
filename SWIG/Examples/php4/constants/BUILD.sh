#! /bin/sh -e

swig -php4 -phpfull -c++ -noproxy example.i
phpize && ./configure && make clean && make
