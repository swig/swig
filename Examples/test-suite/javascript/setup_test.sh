#!/bin/sh
if [ ! -d $1 ]; then
  mkdir $1;
fi
sed s/\$testcase/$1/ node_template/binding.gyp.in > $1/binding.gyp
sed s/\$testcase/$1/ node_template/index.js.in > $1/index.js
