source("unittest.R")
dyn.load(paste("unions_wrap", .Platform$dynlib.ext, sep=""))
source("unions_wrap.R")
cacheMetaData(1)

ss <- SmallStruct()

bstruct <- BigStruct()

q(save="no")


