import director_minimal

class MyMinimal(director_minimal.Minimal):
    def run(self):
        return True

c = MyMinimal()
if not c.get():
    raise RuntimeError("Should return true")
