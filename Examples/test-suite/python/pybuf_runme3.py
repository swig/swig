import pybuf
buf1 = bytearray(10)
buf2 = bytearray(50)

pybuf.func1(buf1)
assert buf1 == b'a'*10

pybuf.func2(buf2)
assert buf2.startswith(b"Hello world!\x00")

count = pybuf.func3(buf2)
assert count==10 #number of alpha and number in 'Hello world!'

length = pybuf.func4(buf2)
assert length==12
