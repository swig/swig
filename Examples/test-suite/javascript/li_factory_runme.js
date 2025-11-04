var li_factory = require("li_factory");

var circle = li_factory.Geometry.create(li_factory.Geometry.CIRCLE);
var r = circle.radius();
if ((r != 1.5)) {
    throw new Error;
}

var point = li_factory.Geometry.create(li_factory.Geometry.POINT);
var w = point.width();
if ((w != 1.0)) {
    throw new Error;
}
