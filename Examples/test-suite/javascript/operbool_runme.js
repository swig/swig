var operbool = require("operbool");
const b = new operbool.Test();
if (/* await */(b.operator_bool())) {
    throw new Error("operbool failed");
}
