import preproc

if preproc.endif != 1:
  raise RuntimeError

if preproc.define != 1:
  raise RuntimeError

if preproc.defined != 1:
  raise RuntimeError
