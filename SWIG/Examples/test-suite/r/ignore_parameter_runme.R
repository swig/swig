source('unittest.R')
dyn.load('ignore_parameter_wrap.so')
source('ignore_parameter_wrap.R')
cacheMetaData(1)

unittest(jaguar(1, 1.0), "hello")
q(save='no')



