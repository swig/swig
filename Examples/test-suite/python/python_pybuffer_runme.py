# run:
#  python python_pybuffer_runme.py benchmark
# for the benchmark, other wise the test case will be run
import python_pybuffer
import sys

def check(flag):
    if not flag:
        raise RuntimeError("Test failed")

if len(sys.argv) >= 2 and sys.argv[1] == "benchmark":
    # run the benchmark
    import time
    k = 1000000  # number of times to execute the functions

    t = time.time()
    a = bytearray(b"hello world")
    for i in range(k):
        python_pybuffer.title1(a)
    print "Time used by bytearray:", time.time() - t

    t = time.time()
    b = "hello world"
    for i in range(k):
        python_pybuffer.title2(b)
    print "Time used by string:", time.time() - t
else:
    # run the test case
    buf1 = bytearray(10)
    buf2 = bytearray(50)

    python_pybuffer.func1(buf1)
    check(buf1 == b"a" * 10)

    python_pybuffer.func2(buf2)
    check(buf2.startswith(b"Hello world!\x00"))

    count = python_pybuffer.func3(buf2)
    check(count == 10)  # number of alpha and number in 'Hello world!'

    length = python_pybuffer.func4(buf2)
    check(length == 12)

    buf3 = bytearray(b"hello")
    python_pybuffer.title1(buf3)
    check(buf3 == b"Hello")
