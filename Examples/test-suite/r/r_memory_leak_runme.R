clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("r_memory_leak", .Platform$dynlib.ext, sep=""))
source("r_memory_leak.R")
cacheMetaData(1)

a <- Foo();
unittest(Foo_get_count(), 1);
b <- Foo();
unittest(Foo_get_count(), 2);

# Normal behaviour
invisible(trigger_internal_swig_exception("no problem", a));
unittest(Foo_get_count(), 2);
# SWIG exception introduced
result <- tryCatch({
  trigger_internal_swig_exception("null", b);
}, warning = function(w) {
  # print("        Hum... We received a warning, but this should be an error");
  unittest(1,0);
}, error = function(e) {
  # print("        Gotcha!");
  unittest(1,1);
})
unittest(Foo_get_count(), 2);
