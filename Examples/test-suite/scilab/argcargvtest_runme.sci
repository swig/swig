exec("swigtest.start", -1);

largs = ["hi" "hola" "hello"];
checkequal(mainc(largs), 3, "calling mainc");

targs = ["hi" "hola"]
checkequal(mainv(targs, 0), "hi", "calling mainv");
checkequal(mainv(targs, 1), "hola", "calling mainv");

checkequal(mainv("hi", 0), "hi", "calling mainv with a single string");

try
  mainv(1, 1);
  swigtesterror();
catch
end

initializeApp(largs);

exec("swigtest.quit", -1);
