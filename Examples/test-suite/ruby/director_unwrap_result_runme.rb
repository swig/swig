#!/usr/bin/env ruby
#
# This test checks the proper unwrapping of director objects before returning
# a pointer to the (wrapped) instance.
# Unwrapping must not happen for return-by-value and returning higher
# reference levels (pointer to pointer, reference to pointer, etc.), but this
# is already checked by the C++ compiler.
#

require 'swig_assert'

require 'director_unwrap_result'

############################
# test with a regular (non-template) class

class MyElement < Director_unwrap_result::Element
end

class MyStorage < Director_unwrap_result::Storage
  def initialize(e)
    super()
    @elem = e
  end
  def getIt
    @elem.getPtrPtr
  end
end

e = MyElement.new
s = MyStorage.new(e)

swig_assert_equal('s.getElement.class', 'Director_unwrap_result::Element', binding)
swig_assert('s.getElement != e', binding)

# this shows that the director class was unwrapped:
swig_assert_equal('s.getElementPtr.class', 'MyElement', binding)
swig_assert_equal('s.getElementPtr', 'e', binding)

# this shows that the director class was unwrapped:
swig_assert_equal('s.getElementRef.class', 'MyElement', binding)
swig_assert_equal('s.getElementRef', 'e', binding)

# this shows that the director class was unwrapped:
swig_assert_equal('s.getElementPtrTypedef.class', 'MyElement', binding)
swig_assert_equal('s.getElementPtrTypedef', 'e', binding)

# this shows that the director class was unwrapped:
swig_assert_equal('s.getElementRefTypedef.class', 'MyElement', binding)
swig_assert_equal('s.getElementRefTypedef', 'e', binding)

# this is not unwrapped:
swig_assert_equal('s.getElementPtrPtr.class', 'SWIG::TYPE_p_p_Element', binding)
swig_assert_equal('s.getElementPtrPtr.class', 'SWIG::TYPE_p_p_Element', binding)

# this is not unwrapped:
swig_assert_equal('s.getElementPtrRef.class', 'SWIG::TYPE_p_p_Element', binding)
swig_assert_equal('s.getElementPtrRef.class', 'SWIG::TYPE_p_p_Element', binding)

# this is not unwrapped:
swig_assert_equal('s.getElementPtrRefTypedef.class', 'SWIG::TYPE_p_p_Element', binding)
swig_assert_equal('s.getElementPtrRefTypedef.class', 'SWIG::TYPE_p_p_Element', binding)

############################
# test with a template class

class MyElementStorage < Director_unwrap_result::ElementStorage
  def initialize(e)
    super()
    @elem = e
  end
  def getIt
    @elem
  end
end

class MyElementPtrStorage < Director_unwrap_result::ElementPtrStorage
  def initialize(e)
    super()
    @elem = e
  end
  def getIt
    @elem.getPtrPtr
  end
end

class MyElementPtrPtrStorage < Director_unwrap_result::ElementPtrPtrStorage
  def initialize(e)
    super()
    @elem = e
  end
  def getIt
    @elem.getPtrPtrPtr
  end
end

e = MyElement.new

s = MyElementStorage.new(e)
swig_assert_equal('s.getVal.class', 'Director_unwrap_result::Element', binding)
swig_assert('s.getVal != e', binding)
# this shows that the director class was unwrapped:
swig_assert_equal('s.getPtr.class', 'MyElement', binding)
swig_assert_equal('s.getPtr', 'e', binding)
# this shows that the director class was unwrapped:
swig_assert_equal('s.getRef.class', 'MyElement', binding)
swig_assert_equal('s.getRef', 'e', binding)

s = MyElementPtrStorage.new(e)
# this shows that the director class was unwrapped:
swig_assert_equal('s.getVal.class', 'MyElement', binding)
swig_assert_equal('s.getVal', 'e', binding)
swig_assert_equal('s.getPtr.class', 'SWIG::TYPE_p_p_Element', binding)
swig_assert_equal('s.getRef.class', 'SWIG::TYPE_p_p_Element', binding)

s = MyElementPtrPtrStorage.new(e)
swig_assert_equal('s.getVal.class', 'SWIG::TYPE_p_p_Element', binding)
swig_assert_equal('s.getPtr.class', 'SWIG::TYPE_p_p_p_Element', binding)
swig_assert_equal('s.getRef.class', 'SWIG::TYPE_p_p_p_Element', binding)

