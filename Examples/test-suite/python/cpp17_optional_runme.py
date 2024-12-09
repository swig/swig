from cpp17_optional import *

test_optionals = TestOptionals()


# Simple Optional
# -----------------------------------------------------------------------------

# test get simple optional initial
optU32 = test_optionals.getSimpleOptional()

assert optU32 is None or isinstance(optU32, int), "test_optionals.getSimpleOptional(): Expected None or int, got {}".format(repr(optU32))

# test set simple optional
optU32 = 32

test_optionals.setSimpleOptional(optU32)

optU32_after_set = test_optionals.getSimpleOptional()
assert optU32_after_set == 32, "test_optionals.setSimpleOptional(): Expected 32, got {}".format(repr(optU32_after_set))

# test clear simple optional
test_optionals.setSimpleOptional(32)

test_optionals.setSimpleOptional(None)

optU32_after_clear = test_optionals.getSimpleOptional()
assert optU32_after_clear is None, "Expected None after clear, got {}".format(repr(optU32_after_clear))


# String Optional
# -----------------------------------------------------------------------------

# test get string optional initial
optStr = test_optionals.getStringOptional()
assert optStr is None or isinstance(optStr, str), "Expected None or string, got {}".format(repr(optStr))

# test set string optional
optStr = "Hello, World!"

test_optionals.setStringOptional(optStr)

optStr_after_set = test_optionals.getStringOptional()
assert optStr_after_set == "Hello, World!", "Expected 'Hello, World!', got {}".format(repr(optStr_after_set))

# test clear string optional
test_optionals.setStringOptional("Test String")

test_optionals.setStringOptional(None)

optStr_after_clear = test_optionals.getStringOptional()
assert optStr_after_clear is None, "Expected None after clear, got {}".format(repr(optStr_after_clear))


# Custom class Optional
# -----------------------------------------------------------------------------

# test initial get struct optional
optStruct = test_optionals.getStructOptional()
assert optStruct is None or isinstance(optStruct, Struct), "Expected None or Struct, got {}".format(repr(optStruct))

# test set struct optional
struct = Struct()
struct.a = 56
struct.b = 78

test_optionals.setStructOptional(struct)

optStruct_after_set = test_optionals.getStructOptional()
assert isinstance(optStruct_after_set, Struct), "Expected Struct instance, got {}".format(repr(optStruct_after_set))
assert optStruct_after_set.a == 56, "Expected struct.a to be 56, got {}".format(optStruct_after_set.a)
assert optStruct_after_set.b == 78, "Expected struct.b to be 78, got {}".format(optStruct_after_set.b)

# test clear struct optional
struct = Struct()
struct.a = 12
struct.b = 34
test_optionals.setStructOptional(struct)

test_optionals.setStructOptional(None)

optStruct_after_clear = test_optionals.getStructOptional()
assert optStruct_after_clear is None, "Expected None after clear, got {}".format(repr(optStruct_after_clear))


# Primitive type Optionals
# -----------------------------------------------------------------------------

# test primitive optionals initial values
fpTolerance = 1e-6
obj = TestObjectPrimitives(done=True, i=100, f=5.55, d=9.999)

assert obj.getBool() == True, "Expected True, got {}".format(obj.getBool())
assert obj.getInt() == 100, "Expected 100, got {}".format(obj.getInt())
assert obj.getFloat() <= 5.55 + fpTolerance and obj.getFloat() >= 5.55 - fpTolerance, "Expected 5.55, got {}".format(obj.getFloat())
assert obj.getDouble() <= 9.999 + fpTolerance and obj.getDouble() >= 9.999 - fpTolerance, "Expected 9.999, got {}".format(obj.getDouble())

# test set and get bool optional
obj = TestObjectPrimitives(done=False, i=101, f=10.10, d=20.202)

obj.setBool(True)
assert obj.getBool() == True, "Expected True, got {}".format(obj.getBool())

obj.setBool(False)
assert obj.getBool() == False, "Expected False, got {}".format(obj.getBool())

# test set and get int optional
obj = TestObjectPrimitives(done=True, i=102, f=20.20, d=30.303)

obj.setInt(99)
assert obj.getInt() == 99, "Expected 99, got {}".format(obj.getInt())

# test set and get float optional
tolerance = 1e-6
obj = TestObjectPrimitives(done=False, i=103, f=30.30, d=40.404)

obj.setFloat(1.23)
assert obj.getFloat() <= 1.23 + tolerance and obj.getFloat() >= 1.23 - tolerance, "Expected 1.23, got {}".format(obj.getFloat())

# test set and get double optional
tolerance = 1e-6
obj = TestObjectPrimitives(done=True, i=104, f=40.40, d=50.505)

obj.setDouble(3.14159)
assert obj.getDouble() == 3.14159, "Expected 3.14159, got {}".format(obj.getDouble()) #CHECKME tolerance?

# test clear bool optional
obj = TestObjectPrimitives(done=False, i=105, f=50.50, d=60.606)

obj.setBoolOpt(True)
assert obj.getBoolOpt() == True, "Expected True, got {}".format(obj.getBoolOpt())

obj.setBoolOpt(None)
assert obj.getBoolOpt() is None, "Expected None, got {}".format(obj.getBoolOpt())

# test clear int optional
obj = TestObjectPrimitives(done=True, i=106, f=60.60, d=70.707)

obj.setIntOpt(123)
assert obj.getIntOpt() == 123, "Expected 123, got {}".format(obj.getIntOpt())

obj.setIntOpt(None)
assert obj.getIntOpt() is None, "Expected None, got {}".format(obj.getIntOpt())

# test clear float optional
tolerance = 1e-6
obj = TestObjectPrimitives(done=False, i=107, f=70.70, d=80.808)

obj.setFloatOpt(4.56)
assert obj.getFloatOpt() <= 4.56 + tolerance and obj.getFloatOpt() >= 4.56 - tolerance, "Expected 4.56, got {}".format(obj.getFloatOpt())

obj.setFloatOpt(None)
assert obj.getFloatOpt() is None, "Expected None, got {}".format(obj.getFloatOpt())

# test clear double optional
obj = TestObjectPrimitives(done=True, i=108, f=80.80, d=90.909)

obj.setDoubleOpt(6.789)
assert obj.getDoubleOpt() == 6.789, "Expected 6.789, got {}".format(obj.getDoubleOpt())

obj.setDoubleOpt(None)
assert obj.getDoubleOpt() is None, "Expected None, got {}".format(obj.getDoubleOpt())

# test get nullopt optional
obj = TestObjectPrimitives(done=False, i=109, f=90.90, d=100.100)

assert obj.getNullopt() is None, "Expected None, got {}".format(obj.getNullopt())


# std types Optionals
# -----------------------------------------------------------------------------

# test std::string initial optional
obj = TestObjectString("InitialName")

assert obj.getName() == "InitialName", "Expected 'InitialName', got {}".format(obj.getName())

# test set and get std::string optional
obj = TestObjectString("AnotherName")

obj.setName("NewName")
assert obj.getName() == "NewName", "Expected 'NewName', got {}".format(obj.getName())

# test clear std::string optional
obj = TestObjectString("OptionalTest")

obj.setNameOpt("OptionalName")
assert obj.getNameOpt() == "OptionalName", "Expected 'OptionalName', got {}".format(obj.getNameOpt())

obj.setNameOpt(None)
assert obj.getNameOpt() is None, "Expected None, got {}".format(obj.getNameOpt())

# test set and get empty std::string optional
obj = TestObjectString("")

assert obj.getName() == "", "Expected empty string, got '{}'".format(obj.getName())

obj.setName("")
assert obj.getName() == "", "Expected empty string, got '{}'".format(obj.getName())

# test empty std::string optional
obj = TestObjectString("NonEmpty")

obj.setNameOpt("")
assert obj.getNameOpt() == "", "Expected empty string, got {}".format(obj.getNameOpt())

obj.setNameOpt(None)
assert obj.getNameOpt() is None, "Expected None, got {}".format(obj.getNameOpt())


# Custom types Optionals
# -----------------------------------------------------------------------------

# test point optional instantiation
point = Point()
assert point.x == 0, "Expected x to be 0, got {}".format(point.x)
assert point.y == 0, "Expected y to be 0, got {}".format(point.y)
assert point.toString() == "Point(0, 0)", "Expected 'Point(0, 0)', got {}".format(point.toString())

point_custom = Point(10, 20)
assert point_custom.x == 10, "Expected x to be 10, got {}".format(point_custom.x)
assert point_custom.y == 20, "Expected y to be 20, got {}".format(point_custom.y)
assert point_custom.toString() == "Point(10, 20)", "Expected 'Point(10, 20)', got {}".format(point_custom.toString())

# test point optional equality
point1 = Point(10, 20)
point2 = Point(10, 20)
point3 = Point(5, 15)

assert point1.isEqual(point2), "Expected point1 to be equal to point2"
assert not point1.isEqual(point3), "Expected point1 to not be equal to point3"

# test circle optional instantiation
circle_default = Circle()
assert circle_default.center is None, "Expected center to be None, got {}".format(circle_default.center)
assert circle_default.radius is None, "Expected radius to be None, got {}".format(circle_default.radius)
assert circle_default.name is None, "Expected name to be None, got {}".format(circle_default.name)
assert circle_default.toString() == "Circle(, , )", "Expected 'Circle(, , )', got {}".format(circle_default.toString())

point = Point(5, 5)
radius = 10
name = "TestCircle"
circle_custom = Circle(point, radius, name)
assert circle_custom.center.isEqual(point), "Expected center to be {}, got {}".format(point, circle_custom.center)
assert circle_custom.radius == radius, "Expected radius to be {}, got {}".format(radius, circle_custom.radius)
assert circle_custom.name == name, "Expected name to be '{}', got {}".format(name, circle_custom.name)
assert (
    circle_custom.toString() == "Circle({}, {}, {})".format(point.toString(), radius, name)
), "Expected 'Circle({}, {}, {})', got {}".format(point.toString(), radius, name, circle_custom.toString())

# test circle optional equality
point1 = Point(10, 10)
point2 = Point(15, 15)

circle1 = Circle(point1, 5, "CircleA")
circle2 = Circle(point1, 5, "CircleA")
circle3 = Circle(point2, 10, "CircleB")

assert circle1.isEqual(circle2), "Expected circle1 to be equal to circle2"
assert not circle1.isEqual(circle3), "Expected circle1 to not be equal to circle3"

# test circle optional property assignment
circle = Circle()

point = Point(3, 4)
radius = 20
name = "UpdatedCircle"

circle.center = point
circle.radius = radius
circle.name = name

assert circle.center.isEqual(point), "Expected center to be {}, got {}".format(point, circle.center)
assert circle.radius == radius, "Expected radius to be {}, got {}".format(radius, circle.radius)
assert circle.name == name, "Expected name to be '{}', got '{}'".format(name, circle.name)

assert (
    circle.toString() == "Circle({}, {}, {})".format(point.toString(), radius, name)
), "Expected 'Circle({}, {}, {})', got {}".format(point.toString(), radius, name, circle.toString())

# test circle optional handling
circle = Circle()

point = Point(10, 10)
radius = 15
name = "TestCircle"

circle.center = point
circle.radius = radius
circle.name = name

assert circle.center.isEqual(point), "Expected center to be {}, got {}".format(point, circle.center)
assert circle.radius == radius, "Expected radius to be {}, got {}".format(radius, circle.radius)
assert circle.name == name, "Expected name to be '{}', got '{}'".format(name, circle.name)

circle.center = None
circle.radius = None
circle.name = None

assert circle.center is None, "Expected center to be None, got {}".format(circle.center)
assert circle.radius is None, "Expected radius to be None, got {}".format(circle.radius)
assert circle.name is None, "Expected name to be None, got {}".format(circle.name)

# test custom optional initialization
point = Point(1, 2)  # Assuming Point takes (x, y) arguments
circle = Circle(Point(3, 4), 5, "CircleA")  # Circle takes (center Point, radius, name)

obj = TestObjectCustom(point, circle)

assert obj.getPoint().isEqual(point), "Expected point {}, got {}".format(point.toString(), obj.getPoint().toString())
assert obj.getPointOpt().isEqual(point), "Expected point {}, got {}".format(point.toString(), obj.getPointOpt().toString())
assert obj.getCircleOpt().isEqual(
    circle
), "Expected circle {}, got {}".format(circle.toString(), obj.getCircleOpt().toString())

# test set and get custom optional
point = Point(5, 6)
circle = Circle(Point(7, 8), 10, "CircleB")

obj = TestObjectCustom(point, circle)

new_point = Point(10, 20)
obj.setPoint(new_point)

assert obj.getPoint().isEqual(new_point), "Expected point {}, got {}".format(new_point.toString(), obj.getPoint().toString())

# test set and get custom optional (cleared point)
point = Point(1, 2)
circle = Circle(Point(3, 4), 5, "CircleA")

obj = TestObjectCustom(point, circle)

new_point = Point(15, 25)
obj.setPointOpt(new_point)

assert obj.getPointOpt().isEqual(
    new_point
), "Expected optional point {}, got {}".format(new_point.toString(), obj.getPointOpt().toString())

obj.setPointOpt(None)

assert obj.getPointOpt() is None, "Expected None, got a value"

# test set and get custom optional (cleared circle)
point = Point(1, 2)
circle = Circle(Point(3, 4), 5, "CircleA")

obj = TestObjectCustom(point, circle)

new_circle = Circle(Point(6, 7), 15, "CircleB")
obj.setCircleOpt(new_circle)

assert obj.getCircleOpt().isEqual(
    new_circle
), "Expected optional circle {}, got {}".format(new_circle.toString(), obj.getCircleOpt().toString())

obj.setCircleOpt(None)

assert obj.getCircleOpt() is None, "Expected None, got a value"

# test clear custom optional (clear point & circle)
point = Point(5, 5)
circle = Circle(Point(10, 10), 10, "TestCircle")

obj = TestObjectCustom(point, circle)

new_point = Point(8, 8)
new_circle = Circle(Point(12, 12), 20, "NewCircle")

obj.setPointOpt(new_point)
obj.setCircleOpt(new_circle)

assert obj.getPointOpt().isEqual(
    new_point
), "Expected optional point {}, got {}".format(new_point.toString(), obj.getPointOpt().toString())
assert obj.getCircleOpt().isEqual(
    new_circle
), "Expected optional circle {}, got {}".format(new_circle.toString(), obj.getCircleOpt().toString())

obj.setPointOpt(None)
obj.setCircleOpt(None)

assert obj.getPointOpt() is None, "Expected optional point to be None"
assert obj.getCircleOpt() is None, "Expected optional circle to be None"


# Directed Optionals
# -----------------------------------------------------------------------------

test_default_directed = TestObjectDirected()

# CHECKME: add better description - test default directed doValueOptionalChanged with value
result = test_default_directed.doValueOptionalChanged(42)
assert result == "", "Expected empty string when value is provided."

# CHECKME: add better description - test default directed doValueOptionalChanged with none
result = test_default_directed.doValueOptionalChanged(None)
assert result == "", "Expected empty string when None is passed."

# CHECKME: add better description - test default directed doReferenceOptionalChanged with value
result = test_default_directed.doReferenceOptionalChanged(99)
assert result == "", "Expected empty string when reference value is provided."

# CHECKME: add better description - test default directed doReferenceOptionalChanged with none
result = test_default_directed.doReferenceOptionalChanged(None)
assert result == "", "Expected empty string when None is passed as reference."

# CHECKME: add better description - test default directed onClassReferenceOptionalChanged with value
rect = Rect(5.0, 3.0)
result = test_default_directed.onClassReferenceOptionalChanged(rect)
assert result == "", "Expected empty string when a valid Rect object is provided."

# CHECKME: add better description - test default directed onClassReferenceOptionalChanged with none
result = test_default_directed.onClassReferenceOptionalChanged(None)
assert result == "", "Expected empty string when None is passed as a class reference."


# Derived directed Optionals
# -----------------------------------------------------------------------------

class TestObjectDerived(TestObjectDirected):

    def onValueOptionalChanged(self, value):
        return "None" if value is None else "value: {}".format(value)

    def onReferenceOptionalChanged(self, reference):
        return "None" if reference is None else "reference: {}".format(reference)

    def onClassReferenceOptionalChanged(self, reference):
        return "None" if reference is None else "class reference: {}".format(reference.toString())

test_derived_directed = TestObjectDerived()

# CHECKME: add better description - test derived directed doValueOptionalChanged with value
result = test_derived_directed.doValueOptionalChanged(42)
assert result == "value: 42", "Expected 'value: 42' when a valid value is provided."

# CHECKME: add better description - test derived directed doValueOptionalChanged with none
result = test_derived_directed.doValueOptionalChanged(None)
assert result == "None", "Expected 'None' when None is passed."

# CHECKME: add better description - test derived directed doReferenceOptionalChanged with value
result = test_derived_directed.doReferenceOptionalChanged(99)
assert result == "reference: 99", "Expected 'reference: 99' when reference value is provided."

# CHECKME: add better description - test derived directed doReferenceOptionalChanged with none
result = test_derived_directed.doReferenceOptionalChanged(None)
assert result == "None", "Expected 'None' when None is passed as reference."

# CHECKME: add better description - test derived directed doClassReferenceOptionalChanged with value
rect = Rect(5.0, 3.0)
result = test_derived_directed.doClassReferenceOptionalChanged(rect)
assert (
    result == "class reference: {}".format(rect.toString())
), "Expected 'class reference: {}' when a valid Rect object is provided.".format(rect.toString())

# CHECKME: add better description - test derived directed doClassReferenceOptionalChanged with none
result = test_derived_directed.doClassReferenceOptionalChanged(None)
assert result == "None", "Expected 'None' when None is passed as a class reference."
