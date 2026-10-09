clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("char_binary", .Platform$dynlib.ext, sep=""))
source("char_binary.R")
cacheMetaData(1)

t <- Test()
unittest(t$strlen("hile"), 4)
unittest(t$ustrlen("hile"), 4)
unittest(t$strlen(NULL), 0)
unittest(t$ustrlen(NULL), 0)
unittest(grepl("^SWIG:TypeError", error_message(function() t$strlen(character(0)))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() t$strlen(c("a", "b")))), TRUE)
