require 'swig_assert'

require 'multichar_constant'

# Multicharacter constants have type int, not char.
if Multichar_constant::MULTICHAR_AB != Multichar_constant.imulti_ab
  raise RuntimeError, "Invalid value for MULTICHAR_AB."
end
