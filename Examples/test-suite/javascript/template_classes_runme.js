var template_classes = require("template_classes");

// This test is just testing incorrect number of arguments/parameters checking

point = new template_classes.PointInt();

rectangle = new template_classes.RectangleInt();
rectangle.setPoint(point);
rectangle.getPoint();
template_classes.RectangleInt.static_noargs();
template_classes.RectangleInt.static_onearg(1);

fail = true;
try {
    rectangle.setPoint();
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}


fail = true;
try {
    rectangle.getPoint(0);
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    RectangleInt.static_noargs(0);
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    RectangleInt.static_onearg();
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}
