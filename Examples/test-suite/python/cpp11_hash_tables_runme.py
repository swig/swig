import cpp11_hash_tables

def swig_assert_equal(a, b):
	if a != b:
		raise RuntimeError(str(a) + " != " + str(b))

for x in [cpp11_hash_tables.MapIntInt({1:7}),
		  cpp11_hash_tables.MultiMapIntInt({1:7}),
		  cpp11_hash_tables.UnorderedMapIntInt({1:7}),
		  cpp11_hash_tables.UnorderedMultiMapIntInt({1:7})
         ]:

	swig_assert_equal([(k, v) for k, v in x.iteritems()], [(1, 7)])
	swig_assert_equal(x.keys(), [1])
	swig_assert_equal(x.values(), [7])
	swig_assert_equal(x.items(), [(1, 7)])
	swig_assert_equal([k for k in x], [1])
	swig_assert_equal([i for i in x.iterkeys()], [1])
	swig_assert_equal([i for i in x.itervalues()], [7])
	swig_assert_equal([i for i in x.iteritems()], [(1, 7)])

	swig_assert_equal(x[1], 7)
	swig_assert_equal(2 in x, False)
	x[2] = 9
	swig_assert_equal(x[2], 9)
	del x[2]
	swig_assert_equal(2 in x, False)
	swig_assert_equal(x.empty(), False)
	del x[1]
	swig_assert_equal(x.empty(), True)
	swig_assert_equal(1 in x, False)

for x in [cpp11_hash_tables.MultiMapIntInt({1:7}),
		  cpp11_hash_tables.UnorderedMultiMapIntInt({1:7})]:
	x[1] = 9
	swig_assert_equal(sorted([v for k, v in x.iteritems()]), [7, 9])
	swig_assert_equal(len(x), 2)

for x in [cpp11_hash_tables.SetInt([1]),
		  cpp11_hash_tables.MultiSetInt([1]),
		  cpp11_hash_tables.UnorderedSetInt([1]),
		  cpp11_hash_tables.UnorderedMultiSetInt([1])]:

	swig_assert_equal([e for e in x], [1])
	swig_assert_equal(x[0], 1)

	swig_assert_equal(1 in x, True)
	swig_assert_equal(2 in x, False)
	x.append(2)
	swig_assert_equal(2 in x, True)
	x.erase(2)
	swig_assert_equal(x.empty(), False)
	x.erase(1)
	swig_assert_equal(x.empty(), True)

for x in [cpp11_hash_tables.MultiSetInt([1]),
		  cpp11_hash_tables.UnorderedMultiSetInt([1])]:
	x.append(1)
	swig_assert_equal(x.count(1), 2)
	swig_assert_equal(len(x), 2)
