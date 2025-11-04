var example = require("example");

//Call some templated functions
console.log(example.maxint(3,7));
console.log(example.maxdouble(3.14,2.18));

// Create some class

var iv = new example.vecint(100);
var dv = new example.vecdouble(1000);

for(let i=0;i<100;i++)
      iv.setitem(i,2*i);

for(let i=0;i<1000;i++)
      dv.setitem(i, 1.0/(i+1));

var sum = 0;
for(let i=0;i<100;i++)
      sum = sum + iv.getitem(i);

console.log(sum);

sum = 0.0;
for(let i=0;i<1000;i++)
      sum = sum + dv.getitem(i);
console.log(sum);

//delete iv;
//delete dv;
