import random
import sys
import unittest
from test_utils import random_string, run_threaded
from argcargvtest import initializeApp, mainc, mainv


class TestArgcArgv(unittest.TestCase):
    def test_list_args(self):
        args = ["hi", "hola"]
        assert mainc(args) == 2
        assert mainv(args, 0) == "hi"
        assert mainv(args, 1) == "hola"
        # These constant strings are injected by mainv; see argcargvtest.i
        assert mainv(args, 2) == "<<NULL>>"  # char **argv is NULL-terminated
        assert mainv(args, 3) == "<<OUT OF BOUNDS>>"
        initializeApp(args)

    def test_tuple_args(self):
        args = ("hi", "hola")
        assert mainc(args) == 2
        assert mainv(args, 0) == "hi"
        assert mainv(args, 1) == "hola"
        assert mainv(args, 2) == "<<NULL>>"
        assert mainv(args, 3) == "<<OUT OF BOUNDS>>"
        initializeApp(args)

    def test_empty_args(self):
        assert mainc([]) == 0
        assert mainv([], 0) == "<<NULL>>"
        assert mainv([], 1) == "<<OUT OF BOUNDS>>"
        assert mainc(()) == 0
        assert mainv((), 0) == "<<NULL>>"
        assert mainv((), 1) == "<<OUT OF BOUNDS>>"
        initializeApp([])
        initializeApp(())

    def test_empty_strings(self):
        args = ["hello", "", "world"]
        assert mainc(args) == 3
        assert mainv(args, 0) == "hello"
        assert mainv(args, 1) == ""
        assert mainv(args, 2) == "world"
        assert mainv(args, 3) == "<<NULL>>"
        assert mainv(args, 4) == "<<OUT OF BOUNDS>>"
        initializeApp(args)

    def test_bytes_args(self):
        args = [b"hello"]
        if sys.version_info < (3,):
            assert mainc(args) == 1
            assert mainv(args, 0) == "hello"
        else:
            with self.assertRaises(TypeError):
                mainc(args)

    def test_bad_sequence(self):
        # Container is neither a list nor tuple
        with self.assertRaises(TypeError):
            mainc(1)
        with self.assertRaises(TypeError):
            mainc("hello")  # strings are Sequences but not legal here

    def test_bad_elements(self):
        with self.assertRaises(TypeError):
            mainc([1])
    
    def test_bad_args_memory_leak(self):
        # Allocate argv and some of its elements, then raise.
        # valgrind or similar should not report any memory leaks after running this test.
        with self.assertRaises(TypeError):
            mainc(["x", "this is a long string", 1])

    def test_threading_race_conditions(self):
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
                    args.append(random_string())
                else:
                    idx = random.randint(0, nargs - 1)
                    try:
                        del args[idx]
                    except IndexError:  # Race condition
                        pass
                # Race conditions will cause this to segfault unless SWIG_AsArgcArgv is
                # protected by a lock.
                nargs = mainc(args)
                assert 0 <= nargs <= MAX_WORKERS * NITER, nargs
                if nargs:
                    idx = random.randint(0, nargs - 1)
                    elem = mainv(args, idx)
                    # Either return an element or, in case of race condition, <<NULL>>
                    assert isinstance(elem, str)
                    # It's very likely the last element is out of bounds by now
                    elem = mainv(args, nargs - 1)
                    assert isinstance(elem, str)

        run_threaded(torture, max_workers=MAX_WORKERS)


if __name__ == '__main__':
    unittest.main()