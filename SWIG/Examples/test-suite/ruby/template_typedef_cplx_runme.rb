require 'template_typedef_cplx'

include Template_typedef_cplx

#
# double case
#

begin
  d = make_Identity_double()
# a = d.this
rescue
  raise RuntimeError, "#{d} is not an instance"
end

classname = d.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{d} is not an ArithUnaryFunction"
end

begin
  e = make_Multiplies_double_double_double_double(d, d)
# a = e.this
rescue
  raise RuntimeError, "#{e} is not an instance"
end

classname = e.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{e} is not an ArithUnaryFunction"
end


#
# complex case
#

begin
  c = make_Identity_complex()
# a = c.this
rescue
  raise RuntimeError, "#{c}is not an instance"
end

classname = c.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{c} is not an ArithUnaryFunction"
end

begin
  f = make_Multiplies_complex_complex_complex_complex(c, c)
# a = f.this
rescue
  raise RuntimeError, "{f} is not an instance"
end

classname = f.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{f} is not an ArithUnaryFunction"
end

#
# Mix case
#

begin
  g = make_Multiplies_double_double_complex_complex(d, c)
# a = g.this
rescue
  raise RuntimeError, "#{g} is not an instance"
end

classname = g.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{g} is not an ArithUnaryFunction"
end


begin
  h = make_Multiplies_complex_complex_double_double(c, d)
# a = h.this
rescue
  raise RuntimeError, "#{h} is not an instance"
end

classname = h.class.name.split(/::/).last
unless classname =~ /ArithUnaryFunction/
  raise RuntimeError, "#{h} is not an ArithUnaryFunction"
end

