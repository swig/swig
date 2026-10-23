clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("arrays_dimensionless", .Platform$dynlib.ext, sep=""))
source("arrays_dimensionless.R")
cacheMetaData(1)

unittest(arr_short(1:4, 3), 6)
unittest(arr_ushort(1:4, 3), 6)
unittest(arr_int(1:4, 3), 6)
unittest(arr_uint(1:4, 3), 6)
unittest(arr_long(1:4, 3), 6)
unittest(arr_ulong(1:4, 3), 6)
unittest(arr_ll(1:4, 3), 6)
unittest(arr_ull(1:4, 3), 6)
unittest(arr_float(as.numeric(1:4), 3), 6)
unittest(arr_double(as.numeric(1:4), 3), 6)

unittest(arr_int_isnull(1:2), 0)
unittest(arr_int_isnull(NULL), 1)
unittest(arr_int_isnull(integer(0)), 0)
unittest(arr_double_isnull(c(1.5, 2.5)), 0)
unittest(arr_double_isnull(NULL), 1)
unittest(arr_double_isnull(numeric(0)), 0)
unittest(arr_enum_isnull(NULL), 1)
unittest(arr_enum_isnull(integer(0)), 0)
unittest(arr_enum_second(c("arr_enum1", "arr_enum2")), 1)
unittest(arr_enum_second(c(1L, 0L)), 0)
unittest(arr_enum_second("arr_enum2"), 0)
unittest(grepl("^SWIG:OverflowError", error_message(function() arr_enum_second(c("arr_enum1", "arr_enum2", "arr_enum1")))), TRUE)
unittest(arr_x_isnull(c(1.5, 2.5)), 0)
unittest(arr_x_isnull(NULL), 1)
unittest(arr_x_isnull(numeric(0)), 0)

q(save="no")



