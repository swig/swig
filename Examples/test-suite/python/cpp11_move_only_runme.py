import cpp11_move_only

thing1 = cpp11_move_only.MoveOnly(1)
assert thing1.value() == 1, '{} != 1'.format(thing.value)

# thing2 = cpp11_move_only.factory(1)
# assert thing2.value() == 1, '{} != 1'.format(thing.value)
