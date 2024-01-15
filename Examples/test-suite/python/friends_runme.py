import friends

def check_equal(a, b):
    if a != b:
        raise RuntimeError("Not equal {} != {}".format(a, b))

a = friends.A(2)

if friends.get_val1(a) != 2:
    raise RuntimeError
if friends.get_val2(a) != 4:
    raise RuntimeError
if friends.get_val3(a) != 6:
    raise RuntimeError

# nice overload working fine
if friends.get_val1(1, 2, 3) != 1:
    raise RuntimeError

b = friends.B(3)

# David's case
if friends.mix(a, b) != 5:
    raise RuntimeError

di = friends.D_i(2)
dd = friends.D_d(3.3)

# incredible template overloading working just fine
if friends.get_val1(di) != 2:
    raise RuntimeError
if friends.get_val1(dd) != 3.3:
    raise RuntimeError

friends.set(di, 4)
friends.set(dd, 1.3)

if friends.get_val1(di) != 4:
    raise RuntimeError
if friends.get_val1(dd) != 1.3:
    raise RuntimeError

if friends.chum_blah() != 1234:
  raise RuntimeError("failed")
if friends.mate_blah() != 4321:
  raise RuntimeError("failed")

foe = friends.Foe(111)
check_equal(friends.friend_definition(), 10)
check_equal(friends.friend_declaration(), 11)
check_equal(friends.friend_args_definition(foe), 111)
check_equal(friends.friend_args_declaration(foe), 111)

check_equal(friends.friend_definition_compiler(), 20)
check_equal(friends.friend_declaration_compiler(), 21)
check_equal(friends.friend_args_definition_compiler(foe), 111)
check_equal(friends.friend_args_declaration_compiler(foe), 111)
