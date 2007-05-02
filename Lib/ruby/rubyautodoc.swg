/**
 * @file   rubyautodoc.swg
 * @author gga
 * @date   Wed May  2 16:41:59 2007
 * 
 * @brief  This file implements autodoc typemaps for some common
 *         ruby methods.
 * 
 * 
 */

%define AUTODOC(func, str)
  %feature("autodoc", str) func;
%enddef


AUTODOC(to_a, "Convert class to an Array");
AUTODOC(to_s, "Convert class to a String representation");
AUTODOC(inspect, "Inspect class and its contents");
AUTODOC(__getitem__, "Element accessor/slicing");
AUTODOC(__setitem__, "Element setter/slicing");
AUTODOC(operator==, "Equality comparison operator");
AUTODOC(operator<=, "Lower or equal comparison operator");
AUTODOC(operator>=, "Higher or equal comparison operator");
AUTODOC(operator<, "Lower than comparison operator");
AUTODOC(operator>, "Higher than comparison operator");
AUTODOC(operator<<, "Left shifting or appending operator");
AUTODOC(operator>>, "Right shifting operator or extracting operator");
AUTODOC(operator+, "Add operator");
AUTODOC(operator-, "Substraction operator");
AUTODOC(operator+(), "Positive operator");
AUTODOC(operator-(), "Negation operator");
AUTODOC(operator&, "AND operator");
AUTODOC(operator|, "OR operator");
AUTODOC(operator^, "XOR operator");
AUTODOC(operator~, "Invert operator");
AUTODOC(__pow__, "Exponential operator");
AUTODOC(__divmod__, "Modulo of division");
AUTODOC(hash, "Hashing function for class");
AUTODOC(dup, "Create a duplicate of the class and unfreeze it if needed");
AUTODOC(clone, "Create a duplicate of the class");
AUTODOC(coerce, "Coerce class to a number");
AUTODOC(__cmp__, "Comparison operator");
AUTODOC(size, "Size or Length of the container");
AUTODOC(slice, "Return a slice (portion of) the container");
AUTODOC(each, "Iterate thru each element in the container.  A block must be provided");
AUTODOC(find, "Find an element in the class or container");
AUTODOC(each_key, "Iterate thru each key element in the container.  A block must be provided");
AUTODOC(each_value, "Iterate thru each key element in the container.  A block must be provided");
AUTODOC(reject, "Iterate thru each element in the container and reject those that fail a condition returning a new container.  A block must be provided");
AUTODOC(reject_bang, "Iterate thru each element in the container and reject those that fail a condition.  A block must be provided.  Container is modified in place");
AUTODOC(select, "Iterate thru each element in the container and select those that match a condition.  A block must be provided");


