director_minimal

function self=MyMinimal()
  global director_minimal;
  self=subclass(director_minimal.Minimal());
  self.run=@MyMinimal_run;
end
function ret=MyMinimal_run(self)
  ret = true;
end

c = MyMinimal();
if (!c.get())
  error("Should return true");
end
