import threads_exception

t = threads_exception.Test()
try:
  t.unknown()
except RuntimeError,e:
  pass

try:
  t.simple()
except RuntimeError,e:
  if e.args[0] != 37:
    raise RuntimeError

try:
  t.message()
except RuntimeError,e:
  if e.args[0] != "I died.":
    raise RuntimeError

try:
  t.hosed()
except threads_exception.Exc,e:
  if e.code != 42:
    raise RuntimeError
  if e.msg != "Hosed":
    raise RuntimeError

for i in range(1,4):
  try:
    t.multi(i)
  except RuntimeError,e:
    pass
  except threads_exception.Exc,e:
    pass

