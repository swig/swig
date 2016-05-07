%rename(dequeWithSizeAndVal) std::deque::deque(unsigned int size, const T& value);
%rename(dequeWithSize) std::deque::deque(unsigned int size);
%rename(resizeWithVal) std::deque::resize(unsigned int size, T value);

%include <std/_std_deque.i>
