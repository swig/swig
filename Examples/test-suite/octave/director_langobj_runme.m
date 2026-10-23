director_langobj

function self=OctCallback()
  global director_langobj;
  self=subclass(director_langobj.Callback());
  self.callback=@OctCallback_callback;
  self.callback_ref=@OctCallback_callback_ref;
end
function OctCallback_callback(self,param1)
  global received;
  received=param1;
end
function OctCallback_callback_ref(self,param1)
  global received;
  received=param1;
end

global received;

handler = OctCallback();
obj = "test data";

% An opaque proxy would arrive as a swig object rather than the string that was
% passed in.

received = 0;
director_langobj.call_callback(handler,obj);
if (!ischar(received) || !strcmp(received,obj))
  error("callback did not receive the value passed from C++")
endif

received = 0;
director_langobj.call_callback_ref(handler,obj);
if (!ischar(received) || !strcmp(received,obj))
  error("callback_ref did not receive the value passed from C++")
endif
