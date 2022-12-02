clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("template_default_arg_overloaded_extend", .Platform$dynlib.ext, sep=""))
source("template_default_arg_overloaded_extend.R")
cacheMetaData(1)




rs = ResultSet()

unittest(rs$go_get_method(0, SearchPoint()), -1)
unittest(rs$go_get_method(0, SearchPoint(), 100), 100)

unittest(rs$go_get_template(0, SearchPoint()), -2)
unittest(rs$go_get_template(0, SearchPoint(), 100), 100)

unittest(rs$over(), "over(int)")
unittest(rs$over(10), "over(int)")
unittest(rs$over(SearchPoint()), "over(giai2::SearchPoint, int)")
unittest(rs$over(SearchPoint(), 10), "over(giai2::SearchPoint, int)")
unittest(rs$over(T, SearchPoint()), "over(bool, gaia2::SearchPoint, int)")
unittest(rs$over(T, SearchPoint(), 10), "over(bool, gaia2::SearchPoint, int)")
