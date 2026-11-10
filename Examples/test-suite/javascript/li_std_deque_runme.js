var v = require('li_std_deque');

function check(a, b) {
  if (a !== b)
    throw new Error(`Not equal: ${a} ${b}`);
}

// Test constructors for std::deque<int>
var intDeque  = new v.IntDeque();
var intDeque2 = new v.IntDeque(3);
var intDeque3 = new v.IntDeque(4, 42);
var intDeque4 = new v.IntDeque(intDeque3);

// Test constructors for std::deque<double>
var doubleDeque  = new v.DoubleDeque();
var doubleDeque2 = new v.DoubleDeque(3);
var doubleDeque3 = new v.DoubleDeque(4, 42.5);
var doubleDeque4 = new v.DoubleDeque(doubleDeque3);

// Test constructors for std::deque<Real>
var realDeque  = new v.RealDeque();
var realDeque2 = new v.RealDeque(3);
var realDeque3 = new v.RealDeque(4, 42.5);
var realDeque4 = new v.RealDeque(realDeque3);

// average() should return the average of all values in a std::deque<int>
intDeque.push_back(2);
intDeque.push_back(4);
intDeque.push_back(6);
var avg = v.average(intDeque);
check(avg, 4);
check(intDeque.size(), 3);

// half() should return a std::deque<float>, where each element is half
// the value of the corresponding element in the input deque<float>.
// The original deque's contents are unchanged.
realDeque.clear();
realDeque.push_back(5.5);
var halfDeque = v.half(realDeque);
check(halfDeque.getitem(0), 2.75);
check(realDeque.size(), 1);

// halve_in_place() should...
v.halve_in_place(doubleDeque4);
check(doubleDeque4.getitem(0), 21.25);
check(doubleDeque4.getitem(1), 21.25);
check(doubleDeque4.getitem(2), 21.25);
check(doubleDeque4.getitem(3), 21.25);
check(doubleDeque4.size(), 4);
