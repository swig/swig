import cpp11_move_only

thing = cpp11_move_only.factory(1)
# Python3 only:
# assert thing.value == 1, f'{thing.value} != 1'
assert thing.value == 1, '{} != 1'.format(thing.value)
