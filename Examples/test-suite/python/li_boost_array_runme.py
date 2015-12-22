from li_boost_array import *
import sys


def failed(a, b, msg):
    raise RuntimeError, msg + " " + str(list(a)) + " " + str(list(b))


def compare_sequences(a, b):
    if len(a) != len(b):
        failed(a, b, "different sizes")
    for i in range(len(a)):
        if a[i] != b[i]:
            failed(a, b, "elements are different")

def compare_containers(pythonlist, swigarray):
    compare_sequences(pythonlist, swigarray)

ps = [0, 1, 2, 3, 4, 5]

ai = ArrayInt6(ps)

compare_containers(ps, ai)

# Modify content
for i in range(len(ps)):
    ps[i] = (ps[i] + 1) * 10
    ai[i] = (ai[i] + 1) * 10
compare_containers(ps, ai)

# Empty
ai = ArrayInt6()
compare_containers([0, 0, 0, 0, 0, 0], ai)

# Check return
compare_containers(arrayOutVal(), [-2, -1, 0, 0, 1, 2])
compare_containers(arrayOutConstRef(), [-2, -1, 0, 0, 1, 2])
#compare_containers(arrayOutRef(), [-2, -1, 0, 0, 1, 2])
#compare_containers(arrayOutPtr(), [-2, -1, 0, 0, 1, 2])

# Check passing arguments
ai = arrayInVal([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

ai = arrayInConstRef([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

#ai = ArrayInt6([9, 8, 7, 6, 5, 4])
#arrayInRef(ai)
#compare_containers(ai, [90, 80, 70, 60, 50, 40])

#ai = ArrayInt6([9, 8, 7, 6, 5, 4])
#arrayInPtr(ai)
#compare_containers(ai, [90, 80, 70, 60, 50, 40])

