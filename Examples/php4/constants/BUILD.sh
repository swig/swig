#! /bin/sh -e

${SWIG:=swig}  -php4 -make  -noproxy example.i
make
php -d extension_dir=. runme.php4
