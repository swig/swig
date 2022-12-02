clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("template_class_reuse_name", .Platform$dynlib.ext, sep=""))
source("template_class_reuse_name.R")
cacheMetaData(1)





Bool1()$tt()
Bool1False()$ff()

Bool2()$tt()
Bool2False()$ff()

Bool3()$tt()
Bool3False()$ff()

Bool4()$tt()
Bool4False()$ff()


BoolForward1()$tt()
BoolForward1False()$ff()

BoolForward2()$tt()
BoolForward2False()$ff()

BoolForward3()$tt()
BoolForward3False()$ff()

BoolForward4()$tt()
BoolForward4False()$ff()


IntBool1()$tt()
IntBool1False()$ff()

IntBool2()$tt()
IntBool2False()$ff()

IntBool3()$tt()
IntBool3False()$ff()

IntBool4()$tt()
IntBool4False()$ff()

Duplicate2_0_n(Duplicate2_0())
Duplicate3_n(Duplicate3())
