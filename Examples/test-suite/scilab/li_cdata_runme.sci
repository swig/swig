exec("swigtest.start", -1);

// Strings in Scilab can not contain null character same as C
s = "ABC abc";
m = malloc(256);
memmove(m, s);
ss = cdata(m, 7);
if ss <> "ABC abc" then
  swigtesterror("failed");
end

exec("swigtest.quit", -1);
