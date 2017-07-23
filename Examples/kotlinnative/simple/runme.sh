#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ "$1" == clean ]; then
	rm -fv *.bc *.klib *.kexe *.so *.o
	exit 1
fi

if [ -n "$KOTLIN_BIN_DIR" ]; then
	export PATH=$PATH:$KOTLIN_BIN_DIR
fi

SWIG=../../../swig
export SWIG_LIB=../../../Lib

${SWIG} -c++ -kotlinnative example.i || exit 1

g++ -shared -fPIC -o libexample_wrap.so example_wrap.cxx example.c || exit 1

cinterop -target linux -def example.def -o example || exit 1

kotlinc -target linux example_test.kt -library example -produce program -o example_test || exit 1

./example_test.kexe