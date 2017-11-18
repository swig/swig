# import robin as a module in the global namespace

import robin

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")
