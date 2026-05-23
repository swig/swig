import platform
import python_runtime_data_builtin as builtin
import python_runtime_data_nobuiltin as nobuiltin

def swig_assert(a):
    if not a:
        raise RuntimeError("Failed")

# Mac OS fails this test.
# See 'Macintosh OS X installation' on Doc/Manual/Preface.html
# 'Users of OS X should be aware that Darwin handles shared libraries and
#  linking in a radically different way than most Unix systems.'
if platform.system() != 'Darwin':
    swig_assert(builtin.is_python_builtin())
    swig_assert(not nobuiltin.is_python_builtin())

    for i in range(1, 5):
        v1 = builtin.vectord([1.] * i)
        swig_assert(len(v1) == i)
        v2 = nobuiltin.vectord([1.] * i)
        swig_assert(len(v2) == i)
