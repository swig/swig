#! /bin/sh -e

${SWIG:=swig}  -php4 -make -c++ -noproxy -withcxx example.cxx example.i
make
php -d extension_dir=. runme.php4
