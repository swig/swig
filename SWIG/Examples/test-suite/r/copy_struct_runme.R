source('unittest.R')
dyn.load('copy_struct_wrap.so')
source('copy_struct_wrap.R')
cacheMetaData(1)

a <- getA()

r = getARef()

unittest(A_d_get(r), 42)
unittest(r$d, 42)
unittest(r$i, 20)

# An error in trying to access a field that doesn't exist.
try(r$foo) 

r$d <- pi
unittesttol(r$d, 3.141593, 0.0001)
r$i <- -100

r$ui
r$ui <- 10

 # An error since i is unsigned and so must  be positive.
try(r$ui <- -10)


a = A()
unittest(a$i,0)
unittest(a$d,0)
unittest(a$ui,0)
a$ui <- 100
unittest(a$ui,100)
a$d = 1
unittest(a$d,1)

d <- bar()
unittest(class(d), "_p_D")
unittest(d$x, 1)
unittest(d$u, 0)


la <- new("A");
la@ui <- 5

other = A()
foo <- copyToC(la, other)

aa = A()
aa$i = 201
aa$d = pi
aa$str = 'foo'
copyToR(aa)


