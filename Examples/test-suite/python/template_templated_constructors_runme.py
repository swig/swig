from template_templated_constructors import *

t1 = TConstructor1(123)
t2a = TConstructor2()
t2b = TConstructor2(123)

tc1 = TClass1Int(123.4)
tc2a = TClass2Int()
tc2b = TClass2Int(123.4)

double_pair = DoublePair(1.1, 2.2)
short_pair = ShortPair(0, 1)
string_pair = StringPair("10", "11")
ip1 = IntPair()
ip2 = IntPair(20, 21)
ip3 = IntPair(ip1)
ip4 = IntPair(short_pair)
# These next two create an IntPair from factory function calls in Python, unlike Java which calls the IntPair constructor
ip5 = Pair(double_pair)
ip6 = MakeStringPair(string_pair)
