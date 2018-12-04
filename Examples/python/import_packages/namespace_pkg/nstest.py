import sys
import os
import shutil
import subprocess
import zipfile


def copyMods():
    dirs = ['path1', 'path2', 'path3']

    # Clean out any old package paths
    for d in dirs:
        if os.path.isdir(d):
            shutil.rmtree(d)

    for d in dirs:
        os.mkdir(d)
        os.mkdir(os.path.join(d, 'brave'))

    shutil.copy('robin.py', os.path.join('path1', 'brave'))
    subprocess.check_call('cp _robin.* ' + os.path.join('path1', 'brave'), shell=True)

    shutil.copy('robin.py', os.path.join('path2', 'brave'))
    subprocess.check_call('cp _robin.* ' + os.path.join('path3', 'brave'), shell=True)

    mkzip()

def mkzip():
    zf = zipfile.ZipFile("path4.zip", "w")
    zf.writestr("brave/", b'')
    zf.write('robin.py', 'brave/robin.py')
    zf.close()


def main():
    copyMods()

    # Run each test with a separate interpreter
    subprocess.check_call(sys.executable + " nonpkg.py", shell=True)
    subprocess.check_call(sys.executable + " normal.py", shell=True)
    subprocess.check_call(sys.executable + " split.py", shell=True)
    subprocess.check_call(sys.executable + " zipsplit.py", shell=True)


if __name__ == "__main__":
    main()
