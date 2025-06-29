director_rev_len_str

function self=DirectorReverseLengthStringCallback()
  global director_rev_len_str;
  self=subclass(director_rev_len_str.Callback());
  self.run=@DirectorReverseLengthStringCallback_run;
end
function ret=DirectorReverseLengthStringCallback_run(self, dataBufferAA)
  ret = 0;
  for i = 1:length(dataBufferAA)
    ret = ret + double(dataBufferAA(i)) * 2;
  end
end

callback = DirectorReverseLengthStringCallback();
caller = director_rev_len_str.Caller(callback);
sum = caller.call();

if (sum != 9*2*8)
    error(sum);
end
