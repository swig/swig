var li_factory = require("li_factory");

var circle = /* await */(li_factory.Geometry.create(li_factory.Geometry.CIRCLE));
var r = /* await */(circle.radius());
if ((r != 1.5)) {
    throw new Error;
}

var point = /* await */(li_factory.Geometry.create(li_factory.Geometry.POINT));
var w = /* await */(point.width());
if ((w != 1.0)) {
    throw new Error;
}
