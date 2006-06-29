# This file illustrates the shadow-class C++ interface generated
# by SWIG.

dyn.load('double_delete_wrap.so')
source('double_delete_wrap.R')
cacheMetaData(1)

# ----- Object creation -----

f <- Foo(2.0)
delete(f);
delete(f);