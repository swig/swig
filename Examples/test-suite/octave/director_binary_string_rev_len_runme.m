director_binary_string_rev_len

function self=DirectorReverseLengthStringCallback()
  global director_binary_string_rev_len;
  self=subclass(director_binary_string_rev_len.Callback());
  self.run=@DirectorReverseLengthStringCallback_run;
end
function ret=DirectorReverseLengthStringCallback_run(self, dataBufferAA)
  ret = 0;
  for i = 1:length(dataBufferAA)
    ret = ret + double(dataBufferAA(i)) * 2;
  end
end

callback = DirectorReverseLengthStringCallback();
caller = director_binary_string_rev_len.Caller(callback);
sum = caller.call();

if (sum != 9*2*8)
    error(sum);
end
