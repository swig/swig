#! /bin/sh -e

${SWIG:=swig}  -php4 -make example.i
make
php -d extension_dir=. runme.php4
