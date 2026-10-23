clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
dyn.load(paste("charptr_fragment", .Platform$dynlib.ext, sep=""))
source("charptr_fragment.R")
cacheMetaData(1)

unittest(getCharBuf(), "hello")
unittest(getBinaryCharBuf(), "hello")

q(save="no")
