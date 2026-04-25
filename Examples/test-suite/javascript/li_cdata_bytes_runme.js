var li_cdata_bytes = require("li_cdata_bytes");

m = li_cdata_bytes.predefStr();
s = li_cdata_bytes.cdata(m, 512);
// 's' is Uint8Array, verify its property
if (!ArrayBuffer.isView(s) || s.byteLength != 512 ||
    s.length != 512 || s.BYTES_PER_ELEMENT != 1) {
  throw new Error("'s' do not have proper properties");
}
// verify 's' content
for (i = 0; i < 256; i++) {
  if (s[i] != i)
    throw new Error("Wrong value " + s[i] + " at index " + i);
  if (s[i + 256] != i)
    throw new Error("Wrong value " + s[i + 256] + " at index " + (i + 256));
}
// Fill 's' with new content
for (i = 0; i < 256; i++) {
  v = 256 - 1 - i;
  s[i] = v;
  s[i + 256] = v;
}
m2 = li_cdata_bytes.malloc(512);
// Copy 's' into a new allocated memory
li_cdata_bytes.memmove(m2, s);
if (li_cdata_bytes.verifyBytes(m2) != 0) {
  throw new Error("verifyBytes fails");
}
li_cdata_bytes.free(m2);
