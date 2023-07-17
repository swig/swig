var final_c = require("final_c");

/* await */(final_c.init());
f = final_c.final;
if ((f.yval != 123)) {
  throw new Error("f.yval fail");
}
