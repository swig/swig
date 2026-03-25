var li_cdata_carrays_cpp = require("li_cdata_carrays_cpp");

ia = new li_cdata_carrays_cpp.intArray(5);
for(i = 0; i < 5; i++) {
  ia.setitem(i, i * i);
}

y = li_cdata_carrays_cpp.cdata_int(ia.cast(), 5);

const INT_SIZE = 4; // We assume int uses 4 bytes
// The numbers are smaller than 256
// so we can simply sum and skip endian issues
a = [0, 0, 0, 0, 0];
for(j = 0; j < 5; j++) {
  for(i = 0; i < INT_SIZE; i++) {
    a[j] += 0 + y[j * INT_SIZE + i];
  }
}
if (a[0] !== 0 || a[1] !== 1 || a[2] !== 4 || a[3] !== 9 || a[4] !== 16) {
  throw new Error("failed");
}
