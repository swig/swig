require 'template_type_namespace'

include Template_type_namespace

result = foo()
raise RuntimeError unless result[0].is_a? String

