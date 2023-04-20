clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("extend_template_method", .Platform$dynlib.ext, sep=""))
source("extend_template_method.R")
cacheMetaData(1)


em = ExtendMe()

ret_double = em$do_stuff_double(1, 1.1)
unittest(ret_double, 1.1)

ret_string = em$do_stuff_string(1, "hello there")
unittest(ret_string, "hello there")

ret_double = em$do_overloaded_stuff(1.1)
unittest(ret_double, 1.1)

ret_string = em$do_overloaded_stuff("hello there")
unittest(ret_string, "hello there")


unittest(ExtendMe_static_method(123), 123)

em2 = ExtendMe(123)

em = TemplateExtend()

ret_double = em$do_template_stuff_double(1, 1.1)
unittest(ret_double, 1.1)

ret_string = em$do_template_stuff_string(1, "hello there")
unittest(ret_string, "hello there")


ret_double = em$do_template_overloaded_stuff(1.1)
unittest(ret_double, 1.1)

ret_string = em$do_template_overloaded_stuff("hello there")
unittest(ret_string, "hello there")

unittest(TemplateExtend_static_template_method(123), 123)


em2 = TemplateExtend(123)


q(save="no")
