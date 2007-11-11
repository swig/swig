source("unittest.R")
dyn.load(paste("ignore_parameter_wrap", .Platform$dynlib.ext, sep=""))
source("ignore_parameter.R")
cacheMetaData(1)

unittest(jaguar(1, 1.0), "hello")
q(save="no")



