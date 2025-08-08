import contextlib
import random
import string
import sys


def swig_assert(condition, msg="Assertion failed"):
    """Variant of `assert` that is not disabled by the -O flag"""
    if not condition:
        raise AssertionError(msg)

def swig_check(lhs, rhs):
    """More user friendly assert function which shows values in an AssertionError if they are not equal"""
    if not lhs == rhs:
        raise AssertionError("'{lhs}' != '{rhs}', repr(lhs)={lr}, repr(rhs)={rr}".format(lhs=lhs, rhs=rhs, lr=repr(lhs), rr=repr(rhs)))


@contextlib.contextmanager
def swig_assert_raises(exc_cls):
    """Reimplementation of pytest.raises context manager."""
    try:
        yield
    except exc_cls:
        pass
    else:
        raise AssertionError("{} was not raised".format(exc_cls.__name__))


def swig_random_string(length=None):
    if length is None:
        length = random.randint(0, 16)
    domain = string.ascii_letters + string.digits
    if sys.version_info < (3, 6):
        chars = [random.choice(domain) for _ in range(length)]
    else:
        chars = random.choices(domain, k=length)
    return "".join(chars)


def swig_run_threaded(
    func,
    max_workers=8,
    pass_count=False,
    pass_barrier=False,
    outer_iterations=1,
    prepare_args=None,
):
    """Runs a function many times in parallel.
    Copied from numpy/testing/_private/utils.py::run_threaded
    """
    if sys.version_info < (3, 2):
        return
    import concurrent.futures
    import threading

    for _ in range(outer_iterations):
        executor = concurrent.futures.ThreadPoolExecutor(max_workers=max_workers)
        with executor as tpe:
            if prepare_args is None:
                args = []
            else:
                args = prepare_args()
            if pass_barrier:
                barrier = threading.Barrier(max_workers)
                args.append(barrier)
            if pass_count:
                all_args = [[func, i] + args for i in range(max_workers)]
            else:
                all_args = [[func] + args for _ in range(max_workers)]
            try:
                futures = []
                for arg in all_args:
                    futures.append(tpe.submit(*arg))
            except RuntimeError as e:
                print(
                    "Spawning {} threads failed with "
                    "error {} (likely due to resource limits on the "
                    "system running the tests)".format(max_workers, e)
                )
            finally:
                if len(futures) < max_workers and pass_barrier:
                    barrier.abort()
            for f in futures:
                f.result()
