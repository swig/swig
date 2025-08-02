director_binary_string

function self=DirectorBinaryStringCallback()
  global director_binary_string;
  self=subclass(director_binary_string.Callback());
  self.run=@DirectorBinaryStringCallback_run;
  self.writeData=@DirectorBinaryStringCallback_writeData;
end
function ret=DirectorBinaryStringCallback_run(self, dataBufferAA, dataBufferBB)
  ret = 0;
  for i = 1:length(dataBufferAA)
    ret = ret + double(dataBufferAA(i)) * 2;
  end
  for i = 1:length(dataBufferBB)
    ret = ret + double(dataBufferBB(i)) * 3;
  end
end
function ret=DirectorBinaryStringCallback_writeData(self, dataBufferAA)
  ret = 0;
  for i = 1:length(dataBufferAA)
    ret = ret + double(dataBufferAA(i)) * 2;
  end
end

caller = director_binary_string.Caller();
callback = DirectorBinaryStringCallback();
caller.setCallback(callback);
sum = caller.call();
sumData = caller.callWriteData();
caller.delCallback();

if (sum != 9*2*8 + 13*3*5)
    error(sum);
end
if (sumData != 9*2*8)
    error(sumData);
end

% FIXME how do we create null string?
% director_binary_string.Callback().run(null, null);
director_binary_string.Callback().run('', '');
callback = DirectorBinaryStringCallback();
caller.setCallback(callback);
caller.call_null();
caller.delCallback();
