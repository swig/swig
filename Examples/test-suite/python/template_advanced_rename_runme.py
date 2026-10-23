import template_advanced_rename
from swig_test_utils import swig_check

# Both overloads of the function template are instantiated, even though one of the two
# declarations was renamed.
swig_check(template_advanced_rename.spinner(10), 1)
swig_check(template_advanced_rename.spinner(10, 20), 2)
