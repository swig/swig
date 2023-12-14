var iadd = require('iadd');

var f = new iadd.Foo();

f.AsA.x = 3;
/* await */(f.AsA.addto(f.AsA));

if (f.AsA.x != 6)
    throw new Error;
