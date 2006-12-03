source('unittest.R')
dyn.load('unions_wrap.so')
source('unions_wrap.R')
cacheMetaData(1)

ss <- SmallStruct()

bstruct <- BigStruct()

q(save='no')


