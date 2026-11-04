clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("c99_vla_array_libraries", .Platform$dynlib.ext, sep=""))
source("c99_vla_array_libraries.R")
cacheMetaData(1)

# As for a fixed size array, an enum array is converted from enum names and both arrays take character vectors
unittest(sum_colours(2L, c("GREEN", "BLUE")), 3L)
unittest(sum_const_colours(3L, c("GREEN", "BLUE")), 3L)
unittest(attr(sum_colours, "inputTypes"), c("integer", "character"))
unittest(count_names(3L, c("a", "b")), 2L)
unittest(attr(count_names, "inputTypes"), c("integer", "character"))
