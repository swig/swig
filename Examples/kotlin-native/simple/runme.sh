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

${SWIG} -python example.i || exit 1

#gcc -shared -o libexample.so example.c || exit 1

#cinterop -target linux -def example_native.def -o example_native || exit 1

#kotlinc -target linux example.kt -library example_native -produce program -o example_kotlin || exit 1

#./example_kotlin.kexe