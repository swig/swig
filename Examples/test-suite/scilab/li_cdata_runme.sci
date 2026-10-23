exec("swigtest.start", -1);

// Typed list of ascii codes of "ABC\0abc"
s = list(65, 66, 67, 32, 97, 98, 99);
m = malloc(256);
memmove(m, s);
ss = cdata(m, 7);
a = ascii(ss(1)) + ascii(ss(2)) + ascii(ss(3)) + ascii(ss(4)) + ascii(ss(5)) + ascii(ss(6)) + ascii(ss(7));
if a <> "ABC abc" then
  swigtesterror("failed");
end

// Same list using uint8 values
s = list(uint8(65), uint8(66), uint8(67), uint8(32), uint8(97), uint8(98), uint8(99));
memmove(m, s);
ss = cdata(m, 7);
a = ascii(ss(1)) + ascii(ss(2)) + ascii(ss(3)) + ascii(ss(4)) + ascii(ss(5)) + ascii(ss(6)) + ascii(ss(7));
if a <> "ABC abc" then
  swigtesterror("failed");
end

exec("swigtest.quit", -1);
