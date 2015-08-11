source("unittest.R")
dyn.load(paste("preproc_constants", .Platform$dynlib.ext, sep=""))
source("preproc_constants.R")
cacheMetaData(1)

v <- enumToInteger('kValue', '_MyEnum')
print(v)
unittest(v,4)
q(save="no")
