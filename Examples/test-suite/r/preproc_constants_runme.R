clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "preproc_constants"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)


v <- enumToInteger('kValue', '_MyEnum')
print(v)
# temporarily removed until fixed (in progress, see Github patch #500)
unittest(v,4)
q(save="no")
