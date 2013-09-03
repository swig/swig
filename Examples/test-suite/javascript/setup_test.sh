#!/bin/sh
if [ ! -d $1 ]; then
  mkdir $1;
fi
echo "module.exports = require('./build/Release/$1')" > $1/index.js
echo "{\"targets\":[{\"target_name\": \"$1\",\"sources\":[\"$1_wrap.cxx\"]}]}" > $1/binding.gyp
