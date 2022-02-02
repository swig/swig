# file: runme.py

import example

pmap = example.pymap()
pmap["hi"] = 1
pmap["hello"] = 2


dmap = {}
dmap["hello"] = 1.0
dmap["hi"] = 2.0

print(list(dmap.items()))
print(list(dmap.keys()))
print(list(dmap.values()))

print(dmap)
hmap = example.halfd(dmap)
dmap = hmap

print(dmap)
for i in dmap.keys():
    print("key %s" % i)

for i in dmap.values():
    print("val %s" % i)

for k, v in dmap.items():
    print("item %s %s" % (k, v))

dmap = example.DoubleMap()
dmap["hello"] = 1.0
dmap["hi"] = 2.0

for i in dmap.keys():
    print("key %s" % i)

for i in dmap.values():
    print("val %s" % i)

for k, v in dmap.items():
    print("item %s %s" % (k, v))


print(list(dmap.items()))
print(list(dmap.keys()))
print(list(dmap.values()))

hmap = example.halfd(dmap)
print(list(hmap.keys()))
print(list(hmap.values()))


dmap = {}
dmap["hello"] = 2
dmap["hi"] = 4

hmap = example.halfi(dmap)
print(hmap)
print(list(hmap.keys()))
print(list(hmap.values()))


dmap = hmap

for i in dmap.keys():
    print("key %s" % i)

for i in dmap.values():
    print("val %s" % i)

for i in dmap.items():
    print("item %s" % str(i))

for k, v in dmap.items():
    print("item %s %s" % (k, v))

print(dmap)
