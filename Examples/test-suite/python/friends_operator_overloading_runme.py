import friends_operator_overloading

friends_operator_overloading.sanity_checker_ShiftA()
friends_operator_overloading.sanity_checker_ShiftB()

sa1 = friends_operator_overloading.ShiftA(200)
sa2 = friends_operator_overloading.ShiftA(1000)
sb1 = friends_operator_overloading.ShiftB(200)
sb2 = friends_operator_overloading.ShiftB(1000)

# Shift operator via members
sa3 = sa2 << sa1
val = sa3.getVal()
if val != 800:
    raise RuntimeError("Wrong val: {}".format(val))

sa4 = sa2 << 300
val = sa4.getVal()
if val != 700:
    raise RuntimeError("Wrong val: {}".format(val))

sb3 = sb2 << sb1
val = sb3.getVal()
if val != 800:
    raise RuntimeError("Wrong val: {}".format(val))

sb4 = sb2 << 300
val = sb4.getVal()
if val != 700:
    raise RuntimeError("Wrong val: {}".format(val))

# Shift operator via global wrapper
shift = friends_operator_overloading.__lshift__(sa2, sa1)
val = shift.getVal()
if val != 800:
    raise RuntimeError("Wrong val: {}".format(val))

shift = friends_operator_overloading.__lshift__(sb2, sb1)
val = shift.getVal()
if val != 800:
    raise RuntimeError("Wrong val: {}".format(val))
