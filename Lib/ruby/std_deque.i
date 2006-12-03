/* Default std_deque wrapper */
%module std_deque

%rename(__getitem__) std::deque::getitem;
%rename(__setitem__) std::deque::setitem;

%predicate std::deque::empty;

%alias std::deque::push_back	"<<";
%alias std::deque::size		"length";

%include <std/_std_deque.i>
