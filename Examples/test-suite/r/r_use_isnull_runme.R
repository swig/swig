clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("r_use_isnull", .Platform$dynlib.ext, sep=""))
source("r_use_isnull.R")
cacheMetaData(1)

tp <- pointerTest()
circ1 <- tp$getCircle(1)
circ1
unittest(is.null(circ1), TRUE)
