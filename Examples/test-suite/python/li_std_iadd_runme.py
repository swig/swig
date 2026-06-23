from li_std_iadd import *

def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

a = Counter(10)
b = Counter(3)
check(a.val == 10)

# Direct += modifies the object in place
a += b
check(a.val == 13)

# -= also works
a -= b
check(a.val == 10)

# += inside a function (the #3309 scenario)
def func(v):
    v += b

func(a)
check(a.val == 13)

# Calling func twice (would trigger use-after-free before the fix)
func(a)
check(a.val == 16)

# renamed_add_assign behaves identically
a.renamed_add_assign(b)
check(a.val == 19)
