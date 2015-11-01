clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "allprotected"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

EV1 <- enumToInteger("EnumVal1", "_PublicBase__AnEnum")
EV2 <- enumToInteger("EnumVal2", "_PublicBase__AnEnum")
unittest(c(EV1, EV2), c(0, 1))

EV1 <- enumToInteger("EnumVal1", "_ProtectedBase__AnEnum")
EV2 <- enumToInteger("EnumVal2", "_ProtectedBase__AnEnum")
unittest(c(EV1, EV2), c(0,1))

