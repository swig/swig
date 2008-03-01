langobj


x ="hello"
rx = sys.getrefcount(x)
v = identity(x)
rv = sys.getrefcount(v)
if v != x:
    error

if rv - rx != 1:
    error
