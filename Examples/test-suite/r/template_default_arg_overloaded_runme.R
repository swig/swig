
clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("template_default_arg_overloaded", .Platform$dynlib.ext, sep=""))
source("template_default_arg_overloaded.R")
cacheMetaData(1)




pl = PropertyList()
unittest(1, pl$setInt("int", 10))
unittest(1, pl$setInt("int", 10, F))

unittest(2, pl$set("int", pl))
unittest(2, pl$set("int", pl, F))

unittest(3, pl$setInt("int", 10, "int"))
unittest(3, pl$setInt("int", 10, "int", F))


pl = PropertyListGlobal()
unittest(1, pl$setIntGlobal("int", 10))
unittest(1, pl$setIntGlobal("int", 10, F))

unittest(2, pl$set("int", pl))
unittest(2, pl$set("int", pl, F))

unittest(3, pl$setIntGlobal("int", 10, "int"))
unittest(3, pl$setIntGlobal("int", 10, "int", F))


unittest(1, GoopIntGlobal(10))
unittest(1, GoopIntGlobal(10, T))

unittest(2, goopGlobal(3))
unittest(2, goopGlobal())

unittest(3, GoopIntGlobal("int", F))
unittest(3, GoopIntGlobal("int"))


unittest(1, GoopInt(10))
unittest(1, GoopInt(10, T))

unittest(2, goop(3))
unittest(2, goop())

unittest(3, GoopInt("int", F))
unittest(3, GoopInt("int"))

