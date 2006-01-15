require 'naming'


if not Naming
  raise RuntimeError, 'Invalid module name for Naming'
end

if not Naming::MyClass
  raise RuntimeError, 'Invalid class name for MyClass'
end

# Check constant names
if not Naming::MyClass::CONST1
  raise RuntimeError, 'Invalid constant name for CONST1'
end


# Check method names
if not Naming::MyClass.instance_methods.include?('method_one')
  raise RuntimeError, 'Invalid method name for method_one'
end

if not Naming::MyClass.instance_methods.include?('method_two')
  raise RuntimeError, 'Invalid method name for method_two'
end

if not Naming::MyClass.instance_methods.include?('method_three')
  raise RuntimeError, 'Invalid method name for method_three'
end

if not Naming::MyClass.instance_methods.include?('method44_4')
  raise RuntimeError, 'Invalid method name for method44_4'
end

# Check predicate methods
if not Naming::MyClass.instance_methods.include?('predicate_method?')
  raise RuntimeError, 'Invalid method name for predicate_method?'
end

# Check bang methods
if not Naming::MyClass.instance_methods.include?('bang_method!')
  raise RuntimeError, 'Invalid method name for bang_method!'
end

# Run all these methods as a sanity check
if Naming::MyClass::CONST1 != 1
  raise RuntimeError, "Incorrect value for CONST1" 
end

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

if my_class.method44_4 != 4
  raise RuntimeError, "Incorrect value for method44_4" 
end

if my_class.predicate_method? != true
  raise RuntimeError, "Incorrect value for predicate_method?" 
end

if my_class.bang_method! != true
  raise RuntimeError, "Incorrect value for bang_method!" 
end
