def check(got, expected):
  if got is None:  # Absence of comment is equivalent to empty comment.
      got = ''

  if got != expected:
    from difflib import unified_diff
    diff = unified_diff(expected.splitlines(True), got.splitlines(True), "expected", "got")
    raise RuntimeError("Comments don't match:\n" + "".join(diff))
