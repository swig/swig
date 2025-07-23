#!/bin/bash
set -o errexit
set -o pipefail

ACTIVATE=~/miniforge3/bin/activate

# PYTHON_DEP=python=2.7
# export PY2=2
# PYTHON_DEP=python=3.11
PYTHON_DEP=python-freethreading=3.13

git clean -fdx
. $ACTIVATE
mamba create -y -n swig $PYTHON_DEP gcc_linux-64 gxx_linux-64 boost-cpp pcre2
. $ACTIVATE swig
./autogen.sh
./configure --prefix=$CONDA_PREFIX
make
make install
make check-python-version
export SWIG_FEATURES=-nogil
ulimit -c unlimited  # Enable core dumps
# make check-python-examples
# make check-python-test-suite
# make -C Examples/test-suite/python -k -s check
make -C Examples/test-suite/python -k -s argcargvtest.cpptest
