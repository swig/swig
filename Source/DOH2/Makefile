SRCS=doh.cpp string.cpp list.cpp hash.cpp file.cpp fio.cpp test.cpp
OBJS=doh.o string.o list.o hash.o file.o fio.o test.o

CXXFLAGS=-ggdb3 -O0

run_test: test
	./test

test: $(OBJS)
	$(CXX) -ggdb3 -O0 -o test $(OBJS)


