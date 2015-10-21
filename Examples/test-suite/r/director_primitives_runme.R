clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "director_primitives"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)
