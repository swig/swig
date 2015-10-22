clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "abstract_typedef2"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

UnaryField <- enumToInteger("UnaryField", "FieldDim")
BinaryField <- enumToInteger("BinaryField", "FieldDim")

unittest(UnaryField, 0)
unittest(BinaryField, 1)

