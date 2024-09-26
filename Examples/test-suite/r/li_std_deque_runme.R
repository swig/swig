clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_std_deque", .Platform$dynlib.ext, sep=""))
source("li_std_deque.R")
cacheMetaData(1)

# Test constructors for std::deque<int>
intDeque <- IntDeque()
intDeque2 <- IntDeque(3)
intDeque3 <- IntDeque(4, 42)
intDeque4 <- IntDeque(intDeque3)

# Test constructors for std::deque<double>
doubleDeque  <- DoubleDeque()
doubleDeque2 <- DoubleDeque(3)
doubleDeque3 <- DoubleDeque(4, 42.0)
doubleDeque4 <- DoubleDeque(doubleDeque3)

# Test constructors for std::deque<Real>
realDeque  <- RealDeque()
realDeque2 <- RealDeque(3)
realDeque3 <- RealDeque(4, 42.0)
realDeque4 <- RealDeque(realDeque3)

#### unittest(half(testvec), testvec/2)
#### unittest(average(testvec), mean(testvec))
#### ## string vector test
#### vlen <- 13
#### stringvec <- paste(letters[1:vlen], as.character(rnorm(vlen)))
#### unittest(rev(stringvec), RevStringVec(stringvec))

# average() should return the average of all values in a std::deque<int>
IntDeque_push_back(intDeque, 2)
IntDeque_push_back(intDeque, 4)
IntDeque_push_back(intDeque, 6)
avg <- average(intDeque)
unittest(avg, 4.0)

# half() should return a std::deque<float>, where each element is half
# the value of the corresponding element in the input deque<float>.
# The original deque's contents are unchanged.
#
RealDeque_clear(realDeque)
RealDeque_push_back(realDeque, 2.0)
halfDeque = half(realDeque)
unittest(RealDeque_front(halfDeque), 1.0)

#
# halve_in_place() should...
#
halve_in_place(doubleDeque)

q(save="no")
