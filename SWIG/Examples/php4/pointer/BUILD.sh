#! /bin/sh -e

swig -php4 -phpfull -c++ -noproxy -withc example.c example.i
phpize && ./configure && make clean && make
