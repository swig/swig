from li_std_set import *

s = set_string()

s.append("a")
s.append("b")
s.append("c")

sum = ""
for i in s:
    sum = sum + i

if sum != "abc":
    raise RuntimeError

i = s.__iter__()
if next(i) != "a":
    raise RuntimeError
if next(i) != "b":
    raise RuntimeError
if next(i) != "c":
    raise RuntimeError


b = s.begin()
e = s.end()
sum = ""
while (b != e):
    sum = sum + next(b)
if sum != "abc":
    raise RuntimeError

b = s.rbegin()
e = s.rend()
sum = ""
while (b != e):
    sum = sum + next(b)

if sum != "cba":
    raise RuntimeError


si = set_int()

si.append(1)
si.append(2)
si.append(3)
i = si.__iter__()

if next(i) != 1:
    raise RuntimeError
if next(i) != 2:
    raise RuntimeError
if next(i) != 3:
    raise RuntimeError

if si[0] != 1:
    raise RuntimeError

i = s.begin()
next(i)
s.erase(i)

b = s.begin()
e = s.end()
sum = ""
while (b != e):
    sum = sum + next(b)
if sum != "ac":
    raise RuntimeError


b = s.begin()
e = s.end()
if e - b != 2:
    raise RuntimeError

m = b + 1
if m.value() != "c":
    raise RuntimeError


s = pyset()
s.insert((1, 2))
s.insert(1)
s.insert("hello")


sum = ()
for i in s:
    sum = sum + (i,)

if (len(sum) != 3 or (not 1 in sum) or (not "hello" in sum) or (not (1, 2) in sum)):
    raise RuntimeError
