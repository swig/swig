require("import")
import_to_globs("li_factory")
catch_undef_globs() -- catch "undefined" global variables

circle = Geometry_create(Geometry_CIRCLE)
r = circle:radius()
assert(r == 1.5)

point = Geometry_create(Geometry_POINT)
w = point:width()
assert(w == 1.0)
