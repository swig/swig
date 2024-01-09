var template_classes = require("template_classes");

// This test is just testing incorrect number of arguments/parameters checking

var point = new template_classes.PointInt();

var rectangle = new template_classes.RectangleInt();
/* await */(rectangle.setPoint(point));
/* await */(rectangle.getPoint());
/* await */(template_classes.RectangleInt.static_noargs());
/* await */(template_classes.RectangleInt.static_onearg(1));

var fail = true;
try {
    /* @ts-ignore */
    /* await */(rectangle.setPoint());
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}


fail = true;
try {
    /* @ts-ignore */
    /* await */(rectangle.getPoint(0));
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(RectangleInt.static_noargs(0));
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(RectangleInt.static_onearg());
} catch {
    fail = false;
}
if (fail) {
    throw new Error("argument count check failed");
}
