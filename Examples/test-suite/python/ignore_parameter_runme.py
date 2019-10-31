from ignore_parameter import *

def check(a, b):
    if a != b:
        raise RuntimeError("'%s' != '%s'" % (a, b))

check(jaguar(200, 0), "hello")
check(lotus("foo", 1), 101)
check(tvr("bar", 2), 8.8)
check(ferrari(), 101)
check(fiat(17), 17)

car = SportsCars()
check(car.daimler(200, 0), "hello")
check(car.astonmartin("foo", 1), 101)
check(car.bugatti("bar", 2), 8.8)
check(car.lamborghini(), 101)
check(car.maseratti(289), 289)

MiniCooper(200, 0)
MorrisMinor("baz", 0)
FordAnglia("quux", 200)
AustinAllegro()
