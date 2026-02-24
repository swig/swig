var example = require("example");


function check(x, y)
{
  if(x === y) {
    print("check ok: " + x);
    return true;
  } 
  throw new Error("check failed for " + x + " / " + y);
}

check(example.inci(1), 2);
check(example.inci(1, 2), 3);
check(example.incd(1), 1.01);
check(example.incd(1, 2), 1.02);
check(example.incd(1, 3, 1), 4);





 
 
 
