# Delete contents of failing-tests.mk
# cd ~/_code/_build/swig-debug/Examples/test-suite/fortran
# rm summary.txt; make -k check-cpp

from collections import defaultdict
import os.path

class Results(object):
    BUILD_DIR = "/Users/s3j/_code/_build/swig-debug"

    def __init__(self, path):
        self.results = results = defaultdict(list)
        with open(os.path.join(self.BUILD_DIR, path)) as f:
            for line in f:
                (test, result) = line.strip().split('|')
                results[result].append(test)

    def keys(self):
        return reversed(sorted(self.results))

    def __str__(self):
        lines = []
        for k in self.keys():
            lines.append("{:25s}: {:4d}".format(k, len(self.results[k])))
        return "\n".join(lines)

    def dump(self, f, failtxt="FAILING_CPP_TESTS"):
        results = self.results
        for k in self.keys():
            if k == "passed":
                continue
            print('\n#',k, file=f)
            print(failtxt + " += \\\n ", " \\\n  ".join(sorted(results[k])),
                  file=f)

#cppresults = Results("Examples/test-suite/fortran/summary.txt")
#print(cppresults)
#with open("failing-tests.mk", 'w') as f:
#    cppresults.dump(f)

cresults = Results("Examples/test-suite/fortran/summary-c.txt")
print(cresults)
with open("failing-c-tests.mk", 'w') as f:
    cresults.dump(f, "FAILING_C_TESTS")
