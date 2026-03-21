li_cdata_bytes

m = li_cdata_bytes.predefStr();
s = li_cdata_bytes.cdata(m, 0x200);
for i = 0:255
  if (double(s(i + 1)) != i)
    error(strcat("Value ", string(double(s(i + 1))), " should be ", string(i), " at index ", string(i)));
  end
  if (double(s(i + 1 + 256)) != i)
    error(strcat("Value ", string(double(s(i + 1 + 256))), " should be ", string(i), " at index ", string(i + 256)));
  end
end
s2 = "";
for i = 1:256
  d = char(256 - i);
  s2 = [s2 d];
end
s = [s2 s2];
m2 = li_cdata_bytes.malloc(0x200);
li_cdata_bytes.memmove(m2, s);
if (li_cdata_bytes.verifyBytes(m2) < 0)
  error("verifyBytes fail");
end
li_cdata_bytes.free(m2);
