def check(got, expected, expected_builtin=None):
  if got is None:  # Absence of comment is equivalent to empty comment.
      got = ""

  if got != expected:
    import re
    p = re.compile(r"^[+-]([^+-].*\S)?(\s+)$", re.M)

    def make_trailing_spaces_visible(str):
        def replace_trailing_spaces(match):
            res = match.group(0)
            spaces = match.group(2)
            if spaces is not None:
                res = res + "{+%d trailing spaces}" % len(spaces)
            return res
        return re.sub(p, replace_trailing_spaces, str)

    from difflib import unified_diff
    diff = unified_diff(expected.splitlines(True),
                        got.splitlines(True), "expected", "got")
    lines = []
    for line in diff:
        line = make_trailing_spaces_visible(line.strip("\r\n"))
        lines.append(line + "\n")

    raise RuntimeError("Comments don't match:\n" + "".join(lines))
