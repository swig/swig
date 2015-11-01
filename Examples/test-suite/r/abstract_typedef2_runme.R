clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "abstract_typedef2"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

UnaryField <- enumToInteger("UnaryField", "_FieldDim")
BinaryField <- enumToInteger("BinaryField", "_FieldDim")

unittest(c(UnaryField, BinaryField), c(0, 1))

