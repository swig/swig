clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("li_boost_shared_ptr_template", .Platform$dynlib.ext, sep=""))
source("li_boost_shared_ptr_template.R")
cacheMetaData(1)

b = BaseINTEGER()
d = DerivedINTEGER()

unittest(BaseINTEGER_bar(b), 1)
unittest(b$bar(), 1)

unittest(DerivedINTEGER_bar(d), 2)
unittest(d$bar(), 2)

unittest(bar_getter(b), 1)
unittest(bar_getter(d), 2)


b = BaseDefaultInt()
d = DerivedDefaultInt()
d2 = DerivedDefaultInt2()

unittest(BaseDefaultInt_bar2(b), 3)
unittest(b$bar2(), 3)

unittest(DerivedDefaultInt_bar2(d), 4)
unittest(d$bar2(), 4)

unittest(bar2_getter(b), 3)
unittest(bar2_getter(d), 4)
unittest(bar2_getter(d2), 4)


q(save="no")
