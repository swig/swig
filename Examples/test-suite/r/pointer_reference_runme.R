clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("pointer_reference", .Platform$dynlib.ext, sep=""))
source("pointer_reference.R")
cacheMetaData(1)


s = Struct_value_get(Struct_pInstance_get())
unittest(s, 10)

ss = Struct(20)
Struct_pInstance_set(ss)
s = Struct_value_get(Struct_pInstance_get())
unittest(s, 20)

s = overloading(1)
unittest(s, 111)

s = overloading(ss)
unittest(s, 222)


