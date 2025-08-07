import random
import sys
from swig_test_utils import (
    swig_assert,
    swig_assert_raises,
    swig_random_string,
    swig_run_threaded,
)
from argcargvtest import initializeApp, mainc, mainv


def test_list_args():
    args = ["hi", "hola"]
    swig_assert(mainc(args) == 2)
    swig_assert(mainv(args, 0) == "hi")
    swig_assert(mainv(args, 1) == "hola")
    # These constant strings are injected by mainv; see argcargvtest.i
    swig_assert(mainv(args, 2) == "<<NULL>>")  # char **argv is NULL-terminated
    swig_assert(mainv(args, 3) == "<<OUT OF BOUNDS>>")
    initializeApp(args)


def test_tuple_args():
    args = ("hi", "hola")
    swig_assert(mainc(args) == 2)
    swig_assert(mainv(args, 0) == "hi")
    swig_assert(mainv(args, 1) == "hola")
    swig_assert(mainv(args, 2) == "<<NULL>>")
    swig_assert(mainv(args, 3) == "<<OUT OF BOUNDS>>")
    initializeApp(args)


def test_empty_args():
    swig_assert(mainc([]) == 0)
    swig_assert(mainv([], 0) == "<<NULL>>")
    swig_assert(mainv([], 1) == "<<OUT OF BOUNDS>>")
    swig_assert(mainc(()) == 0)
    swig_assert(mainv((), 0) == "<<NULL>>")
    swig_assert(mainv((), 1) == "<<OUT OF BOUNDS>>")
    initializeApp([])
    initializeApp(())


def test_empty_strings():
    args = ["hello", "", "world"]
    swig_assert(mainc(args) == 3)
    swig_assert(mainv(args, 0) == "hello")
    swig_assert(mainv(args, 1) == "")
    swig_assert(mainv(args, 2) == "world")
    swig_assert(mainv(args, 3) == "<<NULL>>")
    swig_assert(mainv(args, 4) == "<<OUT OF BOUNDS>>")
    initializeApp(args)


def test_bytes_args():
    args = [b"hello"]
    if sys.version_info < (3,):
        swig_assert(mainc(args) == 1)
        swig_assert(mainv(args, 0) == "hello")
    else:
        with swig_assert_raises(TypeError):
            mainc(args)


def test_bad_sequence():
    # Container is neither a list nor tuple
    with swig_assert_raises(TypeError):
        mainc(1)
    with swig_assert_raises(TypeError):
        mainc("hello")  # strings are Sequences but not legal here


def test_bad_elements():
    with swig_assert_raises(TypeError):
        mainc([1])


def test_bad_args_memory_leak():
    # Allocate argv and some of its elements, then raise.
    # valgrind or similar should not report any memory leaks after running this test.
    x = "x"
    x += "x"  # constants are immortal
    y = "this is a long string"
    y += "that can be deallocated"
    with swig_assert_raises(TypeError):
        mainc([x, y, 1])


def test_threading_race_conditions():
    # Increase these for local torture testing
    MAX_WORKERS = 4
    NITER = 200

    # Shared list of arguments to be used by all threads
    args = []

    def torture():
        """In 60% of the cases, append a random string to a shared list of
        arguments; otherwise, remove a random element from it, causing the string to
        be dereferenced and the list to shrink.
        Finally call SWIG_AsArgcArgv. Repeat many times.
        """
        for _ in range(NITER):
            nargs = len(args)
            if nargs == 0 or random.random() > 0.4:
                args.append(swig_random_string())
            else:
                idx = random.randint(0, nargs - 1)
                try:
                    del args[idx]
                except IndexError:  # Race condition
                    pass
            # Race conditions will cause this to segfault unless SWIG_AsArgcArgv is
            # thread-safe.
            nargs = mainc(args)
            swig_assert(0 <= nargs <= MAX_WORKERS * NITER, nargs)
            if nargs:
                idx = random.randint(0, nargs - 1)
                elem = mainv(args, idx)
                # Either return an element or, in case of race condition, <<NULL>>
                swig_assert(isinstance(elem, str))
                # It's very likely the last element is out of bounds by now
                elem = mainv(args, nargs - 1)
                swig_assert(isinstance(elem, str))

    swig_run_threaded(torture, max_workers=MAX_WORKERS)


if __name__ == "__main__":
    for k, v in list(globals().items()):
        if k.startswith("test_") and callable(v):
            v()
