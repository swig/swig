#! /bin/sh -e

${SWIG:=swig} -xmlout e.xml -php4 -make -c++ -withcxx example.cxx example.i
make
php -d extension_dir=. runme.php4
