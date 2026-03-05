import python_pyiterator_rename_a
import python_pyiterator_rename_b

# Test module A iterators
ha = python_pyiterator_rename_a.VecHolder_a()
va = ha.get()
it = va.begin()
if not hasattr(it, 'value'):
    raise RuntimeError("module a: iterator missing value() method")
if not hasattr(it, '__next__'):
    raise RuntimeError("module a: iterator missing __next__() method")
if it.value() != 10:
    raise RuntimeError("module a: expected 10, got %d" % it.value())
it.next()
if it.value() != 20:
    raise RuntimeError("module a: expected 20, got %d" % it.value())

# Test module B iterators
hb = python_pyiterator_rename_b.VecHolder_b()
vb = hb.get()
it = vb.begin()
if not hasattr(it, 'value'):
    raise RuntimeError("module b: iterator missing value() method")
if it.value() != 40:
    raise RuntimeError("module b: expected 40, got %d" % it.value())
it.next()
if it.value() != 50:
    raise RuntimeError("module b: expected 50, got %d" % it.value())

# Test that Python-level iteration works via __iter__/__next__
a_list = list(ha.get())
if a_list != [10, 20, 30]:
    raise RuntimeError("module a: list() failed, got %s" % a_list)

b_list = list(hb.get())
if b_list != [40, 50, 60]:
    raise RuntimeError("module b: list() failed, got %s" % b_list)
