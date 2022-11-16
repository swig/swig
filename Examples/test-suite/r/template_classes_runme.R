
clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("template_classes", .Platform$dynlib.ext, sep=""))
source("template_classes.R")
cacheMetaData(1)


# This test is just testing incorrect number of arguments/parameters checking

point = PointInt()
rectangle = RectangleInt()

p = RectangleInt_getPoint(rectangle)
unittest(PointInt_getX(p), 0)

RectangleInt_setPoint(rectangle, point)

unittest(RectangleInt_static_noargs(), 0)
unittest(RectangleInt_static_onearg(12), 12)


argCheckFailed = F
try({
  RectangleInt_setPoint(rectangle)
  argCheckFailed = T
}, silent=T)  
unittest(argCheckFailed, F)


argCheckFailed = F
try({
  RectangleInt_getPoint(rectangle, 0, .copy = F)
  argCheckFailed = T
}, silent=T)  
unittest(argCheckFailed, F)


argCheckFailed = F
try({
  RectangleInt_static_noargs(123, .copy = F)
  argCheckFailed = T
}, silent=T)  
unittest(argCheckFailed, F)



argCheckFailed = F
try({
  RectangleInt_static_onearg()
  argCheckFailed = T
}, silent=T)  
unittest(argCheckFailed, F)


