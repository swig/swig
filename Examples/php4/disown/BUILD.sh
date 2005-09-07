#! /bin/sh -e

${SWIG:=swig}  -php4 -c++ -make -withcxx example.cxx example.i
make
php -d extension_dir=. runme.php4
