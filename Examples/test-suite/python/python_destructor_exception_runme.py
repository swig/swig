import python_destructor_exception
from StringIO import StringIO
import sys

def error_function():
    python_destructor_exception.ClassWithThrowingDestructor().GetBlah()

def runtest():
    attributeErrorOccurred = False
    try:
        error_function()
    except AttributeError, e:
        attributeErrorOccurred = True
    return attributeErrorOccurred

def runtestcaller():
    stderr_saved = sys.stderr
    buffer = StringIO()
    attributeErrorOccurred = False
    try:
        # Suppress stderr while making this call to suppress the output shown by PyErr_WriteUnraisable
        sys.stderr = buffer

        attributeErrorOccurred = runtest()
    finally:
        sys.stderr.flush()
        sys.stderr = stderr_saved

    assert attributeErrorOccurred
    assert buffer.getvalue().count("I am the ClassWithThrowingDestructor dtor doing bad things") >= 1

runtestcaller()
