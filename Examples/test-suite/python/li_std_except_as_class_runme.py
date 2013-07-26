from li_std_except_as_class import *

# std::domain_error hierarchy
try: test_domain_error()
except domain_error: pass
try: test_domain_error()
except logic_error: pass
try: test_domain_error()
except exception: pass
