var v = require('sizet');

var s = 2000;
s = v.test1(s+1);
s = v.test2(s+1);
s = v.test3(s+1);
s = v.test4(s+1);
if (s != 2004)
  throw new Error('failed');
