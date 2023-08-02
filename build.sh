export INSTALL_DIR=/Users/yangxian/dev/install/darwin/

export CXX=clang++
export CC=clang

mkdir build
cd build

export PROJECT=swig
cmake -DCMAKE_CXX_STANDARD=20  \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/$PROJECT  \
  ../
make
make install
cd ../
