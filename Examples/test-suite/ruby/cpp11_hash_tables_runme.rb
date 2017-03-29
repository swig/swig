require 'swig_assert'
require 'cpp11_hash_tables'

[Cpp11_hash_tables::MapIntInt.new({1=>7}),
 Cpp11_hash_tables::MultiMapIntInt.new({1=>7}),
 Cpp11_hash_tables::UnorderedMapIntInt.new({1=>7}),
 Cpp11_hash_tables::UnorderedMultiMapIntInt.new({1=>7})].each{|x|

  swig_assert_equal("x.find_all{|e,k| e == 1}", "[[1,7]]", binding)

  swig_assert_equal("x[1]", "7", binding)
  swig_assert_equal("x[2]", "nil", binding)
  x[2] = 9
  swig_assert_equal("x[2]", "9", binding)
  x.delete(2)
  swig_assert_equal("x[2]", "nil", binding)
  swig_assert_equal("x.empty?", "false", binding)
  x.delete(1)
  swig_assert_equal("x.empty?", "true", binding)
  swig_assert_equal("x.include?(1)", "false", binding)
}

[Cpp11_hash_tables::MultiMapIntInt.new({1=>7}),
 Cpp11_hash_tables::UnorderedMultiMapIntInt.new({1=>7})].each{|x|
  x[1] = 9
  swig_assert_equal("x[1].sort", "[7,9]", binding)
}

[Cpp11_hash_tables::SetInt.new([1]),
 Cpp11_hash_tables::MultiSetInt.new([1]),
 Cpp11_hash_tables::UnorderedSetInt.new([1]),
 Cpp11_hash_tables::UnorderedMultiSetInt.new([1])].each{|x|

  swig_assert_equal("x.find_all{|e| e == 1}", "[1]", binding)

  swig_assert_equal("x.include?(1)", "true", binding)
  swig_assert_equal("x.include?(2)", "false", binding)
  x << 2
  swig_assert_equal("x.include?(2)", "true", binding)
  x.erase(2)
  swig_assert_equal("x.empty?", "false", binding)
  x.erase(1)
  swig_assert_equal("x.empty?", "true", binding)
}

[Cpp11_hash_tables::MultiSetInt.new([1]),
 Cpp11_hash_tables::UnorderedMultiSetInt.new([1])].each{|x|
  x << 1
  swig_assert_equal("x.count(1)", "2", binding)
}

[Cpp11_hash_tables::MapIntInt,
 Cpp11_hash_tables::MultiMapIntInt,
 Cpp11_hash_tables::UnorderedMapIntInt,
 Cpp11_hash_tables::UnorderedMultiMapIntInt,
 Cpp11_hash_tables::SetInt,
 Cpp11_hash_tables::MultiSetInt,
 Cpp11_hash_tables::UnorderedSetInt,
 Cpp11_hash_tables::UnorderedMultiSetInt].each{|k|
  swig_assert("k.include?(Enumerable)", binding)
}
