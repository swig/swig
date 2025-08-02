exec("swigtest.start", -1);

t = new_Test();
str = "hile";
if Test_strlen(t, str) <> 4 then
  swigtesterror("bad multi-arg typemap");
end
// String can not contain null character same as C

exec("swigtest.quit", -1);
