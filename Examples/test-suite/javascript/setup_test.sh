#!/bin/sh
if [ ! -d $1 ]; then
  mkdir $1;
fi
sed -e "s/\$testcase/$1/" -e "s/\$cflags/$2/" < node_template/binding.gyp.in > $1/binding.gyp
sed s/\$testcase/$1/ node_template/index.js.in > $1/index.js
