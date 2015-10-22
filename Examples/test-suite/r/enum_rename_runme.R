clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "enum_rename"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

Jan <- enumToInteger("M_Jan", "Month")
May <- enumToInteger("M_May", "Month")
Dec <- enumToInteger("M_Dec", "Month")
unittest(c(Jan, May, Dec), c(0, 1, 2))
