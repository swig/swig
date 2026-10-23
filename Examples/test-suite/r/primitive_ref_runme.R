clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("primitive_ref", .Platform$dynlib.ext, sep=""))
source("primitive_ref.R")
cacheMetaData(1)

unittest(ref_int(3), 3)
unittest(ref_uint(3), 3)
unittest(ref_short(3), 3)
unittest(ref_ushort(3), 3)
unittest(ref_long(3), 3)
unittest(ref_ulong(3), 3)
unittest(ref_schar(3), 3)
unittest(ref_uchar(3), 3)
unittest(ref_longlong(3), 3)
unittest(ref_ulonglong(3), 3)
unittest(identical(ref_bool(TRUE), TRUE), TRUE)
unittest(ref_float(3.5), 3.5)
unittest(ref_double(3.5), 3.5)
unittest(ref_char("x"), "x")

for (f in c("ref_int", "ref_uint", "ref_short", "ref_ushort", "ref_long", "ref_ulong",
            "ref_schar", "ref_uchar", "ref_longlong", "ref_ulonglong",
            "ref_bool", "ref_float", "ref_double", "ref_char")) {
  unittest(grepl("^SWIG:TypeError", error_message(function() get(f)(NULL))), TRUE)
}

unittest(grepl("^SWIG:TypeError", error_message(function() ref_int(c(1, 2)))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() ref_double(c(1.5, 2.5)))), TRUE)
unittest(grepl("^SWIG:TypeError", error_message(function() ref_bool(c(TRUE, FALSE)))), TRUE)

q(save="no")
