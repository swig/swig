import complextest

a = complex(1,2)

if complextest.Conj(a) != a.conjugate():
  raise RuntimeError, "bad complex mapping"
