require 'template_tbase_template'

include Template_tbase_template

a = make_Class_dd()
raise RuntimeError unless a.test() == "test"

