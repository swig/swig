import director_char_binary_rev_len

class DirectorBinaryStringCallback(director_char_binary_rev_len.Callback):
    def run(self, dataBufferAA):
        ret = 0
        for c in dataBufferAA:
            ret += ord(c) * 2
        return ret


callback = DirectorBinaryStringCallback()
caller = director_char_binary_rev_len.Caller(callback)
sum = caller.call()

if sum != 9*2*8:
    raise RuntimeError("Unexpected sum: {}".format(sum))
