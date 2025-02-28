import director_rev_len_str

class DirectorBinaryStringCallback(director_rev_len_str.Callback):
    def run(self, dataBufferAA):
        ret = 0
        for c in dataBufferAA:
            ret += ord(c) * 2
        return ret


callback = DirectorBinaryStringCallback()
caller = director_rev_len_str.Caller(callback)
sum = caller.call()

if sum != 9*2*8:
    raise RuntimeError("Unexpected sum: {}".format(sum))
