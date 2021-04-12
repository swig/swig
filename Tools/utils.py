import os, subprocess


def check_file_exists(path):
    """
    Checks if a file exists or not.
    """
    return os.path.isfile(path)


def check_dir_exists(path):
    """
    Checks if a folder exists or not.
    """
    return os.path.isdir(path)


def run_command(*args, **kwargs):
    """
    Runs an os command using subprocess module.
    """
    redirect_out = list(map(str.strip, " ".join(args).split(" > ")))
    if len(redirect_out) > 1:
        args, filepath = redirect_out[0].split(), redirect_out[-1]
        kwargs.update(stdout=open(filepath, "w"))
    return subprocess.call(args, **kwargs)
