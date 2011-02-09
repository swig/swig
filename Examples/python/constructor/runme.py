#!/usr/bin/env

import sys
from subprocess import *

proc = Popen([sys.executable, 'runme_baseline.py'], stdout=PIPE)
(stdout, stderr) = proc.communicate()
print stdout

proc = Popen([sys.executable, 'runme_optimized.py'], stdout=PIPE)
(stdout, stderr) = proc.communicate()
print stdout

proc = Popen([sys.executable, 'runme_builtin.py'], stdout=PIPE)
(stdout, stderr) = proc.communicate()
print stdout

