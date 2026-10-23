clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("arrays_null", .Platform$dynlib.ext, sep=""))
source("arrays_null.R")
cacheMetaData(1)

# TODO: the R module does not define the class for the pointer returned when getting an int [2][3] variable
setClass("_p_a_3__int", contains = "ExternalReference")

s <- ArraysNull()
other <- ArraysNull()
arrays_null_fill(other, 10)
s$ints <- other$ints
s$items <- other$items
s$grid <- other$grid
unittest(arrays_null_check(s, 10), 1)

unittest(grepl("^SWIG:NullReferenceError", error_message(function() s$ints <- NULL)), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() s$items <- NULL)), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() s$grid <- NULL)), TRUE)
unittest(arrays_null_check(s, 10), 1)

arrays_null_ints_set(s$ints)
arrays_null_items_set(s$items)
arrays_null_grid_set(s$grid)
unittest(arrays_null_globals_check(10), 1)

unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_ints_set(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_items_set(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_grid_set(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_ints_ref_set(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_bools_set(NULL))), TRUE)
unittest(arrays_null_globals_check(10), 1)

unittest(arrays_null_ints_isnull(NULL), 1)
unittest(arrays_null_ints_unsized_isnull(NULL), 1)
unittest(arrays_null_enums_isnull(NULL), 1)
unittest(arrays_null_enums_unsized_isnull(NULL), 1)
unittest(arrays_null_items_isnull(NULL), 1)
unittest(arrays_null_items_unsized_isnull(NULL), 1)
unittest(arrays_null_bools_isnull(NULL), 1)
unittest(arrays_null_bools_unsized_isnull(NULL), 1)
unittest(arrays_null_chars_isnull(NULL), 1)
unittest(arrays_null_chars_unsized_isnull(NULL), 1)
unittest(arrays_null_strings_isnull(NULL), 1)
unittest(arrays_null_strings_unsized_isnull(NULL), 1)

# An empty vector is not NULL
unittest(arrays_null_ints_isnull(integer(0)), 0)
unittest(arrays_null_ints_unsized_isnull(integer(0)), 0)
unittest(arrays_null_enums_isnull(character(0)), 0)

# A reference to an array cannot be NULL
unittest(grepl("^SWIG:NullReferenceError", error_message(function() arrays_null_ints_ref_first(NULL))), TRUE)

q(save="no")
