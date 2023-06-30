#!/usr/bin/env python
var operbool = require("operbool");
const b = new operbool.Test();
if (b.operator_bool()) {
    throw new Error("operbool failed");
}
