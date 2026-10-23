clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("char_binary_rev_len", .Platform$dynlib.ext, sep=""))
source("char_binary_rev_len.R")
cacheMetaData(1)

t <- Test()
unittest(t$strlen("hile"), 4)
unittest(t$strlen(NULL), 0)

t2 <- Test("hile")
unittest(t2$getisize(), 4)
unittest(t2$strlen("hil"), 3)
