source("unittest.R")
dyn.load(paste("simple_array_wrap", .Platform$dynlib.ext, sep=""))
source("simple_array_wrap.R")
cacheMetaData(1)
initArray()

q(save="no")


