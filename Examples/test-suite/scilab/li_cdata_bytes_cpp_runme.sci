exec("swigtest.start", -1);

m = predefStr();
s = cdata(m, 512);
for i = 0:255
  if s(i + 1) <> i then
    swigtesterror("Value " + string(s(i + 1)) + " should be " + string(i) + " at index " + string(i));
  end
  if s(i + 1 + 256) <> i then
    swigtesterror("Value " + string(s(i + 1 + 256)) + " should be " + string(i) + " at index " + string(i + 256));
  end
end
for i = 1:256
  d = 256 - i
  s(i) = d;
  s(i + 256) = d;
end
m2 = malloc(512);
memmove(m2, s);
if verifyBytes(m2) < 0 then
  swigtesterror("verifyBytes fail");
end
free(m2);

exec("swigtest.quit", -1);
