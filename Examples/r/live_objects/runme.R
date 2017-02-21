# This file illustrates the proxy class C++ interface generated
# by SWIG.

dyn.load(paste("example", .Platform$dynlib.ext, sep=""))
source("example.R")
cacheMetaData(1)

# ----- Object creation -----

print("Creating some objects:");
a <- Foo();
print(paste("    Count:", Foo_get_count()));
b <- Foo();
print(paste("    Count:", Foo_get_count()));

# ----- Test for possible memory leak -----

print(paste("    Let's see a normal behaviour:"));
invisible(verify_no_memory_leak("no problem", a));
print(paste("        The count should be 2:", Foo_get_count()));
if (Foo_get_count() != 2)
{
  stop("Memory leak detected!");
}

print(paste("    Let's see the case where we introduce a SWIG exception:"));
result <- tryCatch({
  verify_no_memory_leak("null", b);
}, warning = function(w) {
  print("        Hum... We received a warning, but this should be an error");
}, error = function(e) {
  print("        Gotcha!");
})
print(paste("        The count should be again 2:", Foo_get_count()));
if (Foo_get_count() != 2)
{
  stop("Memory leak detected!");
}

print ("Goodbye");

