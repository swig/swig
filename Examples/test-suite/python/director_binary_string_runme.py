import director_binary_string

class DirectorBinaryStringCallback(director_binary_string.Callback):
    def run(self, dataBufferAA, dataBufferBB):
        ret = 0
        for c in dataBufferAA:
            ret += ord(c) * 2
        for c in dataBufferBB:
            ret += ord(c) * 3
        return ret
    def writeData(self, dataBufferAA):
        ret = 0
        for c in dataBufferAA:
            ret += ord(c) * 2
        return ret

caller = director_binary_string.Caller()
callback = DirectorBinaryStringCallback()
caller.setCallback(callback)
sum = caller.call()
sumData = caller.callWriteData()
caller.delCallback()

if sum != 9*2*8 + 13*3*5:
    raise RuntimeError("Unexpected sum: {}".format(sum))
if sumData != 9*2*8:
    raise RuntimeError("Unexpected sumData: {}".format(sumData))

# FIXME accessing abstract class or protected constructor
# It does make sense as writeData() is abstract
# director_binary_string.Callback().run(null, null)
callback = DirectorBinaryStringCallback()
caller.setCallback(callback)
caller.call_null()
caller.delCallback()
