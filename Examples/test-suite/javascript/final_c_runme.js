var final_c = require("final_c");

final_c.init();
f = final_c.final;
if ((f.yval != 123)) {
  throw new Error("f.yval fail");
}
