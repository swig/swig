clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "autodoc"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)
