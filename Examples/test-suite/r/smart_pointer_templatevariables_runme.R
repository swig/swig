clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("smart_pointer_templatevariables", .Platform$dynlib.ext, sep=""))
source("smart_pointer_templatevariables.R")
cacheMetaData(1)


d = DiffImContainerPtr_D(create(1234, 5678))
unittest(d$id, 1234)

d$id = 4321
unittest(d$id, 4321)

q(save="no")
