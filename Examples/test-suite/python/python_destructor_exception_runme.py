import python_destructor_exception
from StringIO import StringIO
import sys

#buffer = StringIO()
#sys.stderr = buffer

attributeErrorOccurred = False
try:
    python_destructor_exception.ClassWithThrowingDestructor().GetBlah()
except AttributeError, e:
    attributeErrorOccurred = True

assert attributeErrorOccurred
