clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "allprotected"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

EV1 <- enumToInteger("EnumVal1", "PublicBase_AnEnum")
EV2 <- enumToInteger("EnumVal2", "PublicBase_AnEnum")
unittest(EV1, 0)
unittest(EV2, 1)

EV1 <- enumToInteger("EnumVal1", "ProtectedBase_AnEnum")
EV2 <- enumToInteger("EnumVal2", "ProtectedBase_AnEnum")
unittest(EV1, 0)
unittest(EV2, 1)
