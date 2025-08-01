exec("swigtest.start", -1);

t = new_Test();
str = "hile";
if Test_strlen(t, str) <> 4 then
  swigtesterror("bad multi-arg typemap 1");
end

// String can not contain null character same as C

t2 = new_Test(str);
if Test_getisize(t2) <> 4 then
  swigtesterror("bad multi-arg typemap 3");
end

if Test_strlen(t2, "hilea") <> 5 then
  swigtesterror("bad multi-arg typemap 4");
end

exec("swigtest.quit", -1);
