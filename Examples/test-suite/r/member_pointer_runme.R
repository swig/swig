clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("member_pointer", .Platform$dynlib.ext, sep=""))
source("member_pointer.R")
cacheMetaData(1)

s <- Square(10)
unittest(do_op(s, areapt()), 100)
unittest(do_op(s, perimeterpt()), 40)

# A const reference to a member pointer is passed and returned as the member pointer
unittest(do_op_cref(s, areapt()), 100)
unittest(do_op_cref(s, perimetervar_td_cref()), 40)
unittest(do_op(s, perimetervar_td_cref()), 40)
