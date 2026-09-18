from self_return import Counter

# Direct rebind: f = f.Inc() must not destroy the C++ object
a = Counter(10)
a = a.Inc()
assert a.get_n() == 11, "direct rebind failed: " + str(a.get_n())

# Chained calls: each returns *this
b = Counter(1)
b = b.Inc().Inc().Inc()
assert b.get_n() == 4, "chained calls failed: " + str(b.get_n())

# Method with argument returning *this
c = Counter(5)
d = Counter(3)
c = c.Add(d)
assert c.get_n() == 8, "Add rebind failed: " + str(c.get_n())
