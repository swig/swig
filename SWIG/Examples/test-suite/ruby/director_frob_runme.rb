require 'director_frob'

foo = Director_frob::Bravo.new;
s = foo.abs_method;

raise RuntimeError if s != "Bravo::abs_method()"
