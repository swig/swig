clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("typemap_string_alloc", .Platform$dynlib.ext, sep=""))
source("typemap_string_alloc.R")
cacheMetaData(1)

Custom_Reset()
some_text_set("one")
some_text_set("two")

unittest(Custom_WasAllocated(), TRUE)
unittest(Custom_WasDeallocated(), TRUE)
