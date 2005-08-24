#! /bin/sh -e

${SWIG:=swig}  -php4 -make -c -noproxy -withc example.c example.i
make
php -d extension_dir=. runme.php4
