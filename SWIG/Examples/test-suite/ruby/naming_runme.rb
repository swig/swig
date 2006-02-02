require 'naming'

# Check class names
if not Naming
  raise RuntimeError, 'Invalid module name for Naming'
end

if not Naming::MyClass
  raise RuntimeError, 'Invalid class name for MyClass'
end


# Check constant names / values
if Naming::CONSTANT1 != 1
  raise RuntimeError, "Incorrect value for CONSTANT1" 
end

if Naming::CONSTANT2 != 2
  raise RuntimeError, "Incorrect value for CONSTANT2" 
end

# Check constant names / values
if Naming::CONSTANT3 != 3
  raise RuntimeError, "Incorrect value for CONSTANT3" 
end

if not Naming::methods.include?("constant4")
  raise RuntimeError, "Incorrect mapping for constant4" 
end

if not Naming::methods.include?("constant5")
  raise RuntimeError, "Incorrect mapping for constant5" 
end

if not Naming::methods.include?("constant6")
  raise RuntimeError, "Incorrect mapping for constant6" 
end

if not Naming::TestConstants.instance_methods.include?("constant7")
  raise RuntimeError, "Incorrect mapping for constant7" 
end

if not Naming::TestConstants.methods.include?("constant8")
  raise RuntimeError, "Incorrect mapping for constant8" 
end

# There is no constant9 because it is illegal C++
#if not Naming::TestConstants.instance_methods.include?("constant9")
#  raise RuntimeError, "Incorrect mapping for constant9" 
#end

if Naming::TestConstants::CONSTANT10 != 10
  raise RuntimeError, "Incorrect value for CONSTANT10" 
end

if not Naming::methods.include?("constant11")
  raise RuntimeError, "Incorrect mapping for constant11" 
end


# Check enums
if Naming::constants.include?("Color")
  raise RuntimeError, "Color enum should not be exposed to Ruby" 
end

if Naming::Red != 0
  raise RuntimeError, "Incorrect value for enum RED" 
end

if Naming::Green != 1
  raise RuntimeError, "Incorrect value for enum GREEN" 
end

if Naming::Blue != 2
  raise RuntimeError, "Incorrect value for enum BLUE" 
end


# Check method names
my_class = Naming::MyClass.new()

if my_class.method_one != 1 
  raise RuntimeError, "Incorrect value for method_one" 
end
  
if my_class.method_two != 2
  raise RuntimeError, "Incorrect value for method_two" 
end

if my_class.method_three != 3
  raise RuntimeError, "Incorrect value for method_three" 
end

if my_class.method_44_4 != 4
  raise RuntimeError, "Incorrect value for method_44_4" 
end

if my_class.predicate_method? != true
  raise RuntimeError, "Incorrect value for predicate_method?" 
end

if my_class.bang_method! != true
  raise RuntimeError, "Incorrect value for bang_method!" 
end
