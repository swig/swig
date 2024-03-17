exec("swigtest.start", -1);

largs = ["hi" "hola" "hello"];
checkequal(mainc(largs), 3, "calling mainc");

targs = ["hi" "hola"]
checkequal(mainv(targs, 0), "hi", "calling mainv");
checkequal(mainv(targs, 1), "hola", "calling mainv");
checkequal(mainv(targs, 2), "<<NULL>>", "calling mainv");

checkequal(mainv("hi", 0), "hi", "calling mainv with a single string");

try
  mainv(1, 1);
  swigtesterror();
catch
end

initializeApp(largs);

// Check that an empty array works.
empty_args = [];
checkequal(mainc(empty_args), 0, "calling mainc");
checkequal(mainv(empty_args, 0), "<<NULL>>", "calling mainv");

// Check that empty strings are handled.
empty_string = ["hello", "", "world"];
checkequal(mainc(empty_string), 3, "calling mainc");
checkequal(mainv(empty_string, 0), "hello", "calling mainv");
checkequal(mainv(empty_string, 1), "", "calling mainv");
checkequal(mainv(empty_string, 2), "world", "calling mainv");
checkequal(mainv(empty_string, 3), "<<NULL>>", "calling mainv");

exec("swigtest.quit", -1);
