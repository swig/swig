from li_std_except_as_class import *

try: test_domain_error()
except domain_error: pass

if not is_python_builtin():
  try: test_domain_error()
  except logic_error: pass
  try: test_domain_error()
  except exception: pass
