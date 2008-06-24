# This file illustrates the proxy class C++ interface generated
# by SWIG.

dyn.load(paste("double_delete", .Platform$dynlib.ext, sep=""))
source("double_delete.R")
cacheMetaData(1)

# ----- Object creation -----

f <- Foo(2.0)
delete(f);
delete(f);
