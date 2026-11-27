#!/usr/bin/python3

# Check that no existing anchor in the manual has been renamed or removed.
#
# An anchor, the id of a heading such as <H2 id="Python_nn25"> or an <a name="...">, can be the target of a link from
# outside the SWIG documentation, which renaming or removing the anchor silently breaks. The anchors in the chapters
# are compared with those where the current branch left the given git revision, master by default:
#  - the anchor of a heading that is still there with the same text, but a new anchor, has been renamed: an error
#  - any other anchor that has gone, such as the anchor of a heading that was removed: a warning
#
# Run checkanchors.py --help for usage.

import argparse
import os
import re
import subprocess
import sys

parser = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(prog, width=80),
    description="""\
Check that no existing anchor in the SWIG manual has been renamed or removed.

An anchor is the id of a heading, such as <H2 id="Python_nn25">, the name of the
anchor in a heading in the older form, <H2><a name="Python_nn25">, or any other
<a name="...">. A link to an anchor can come from outside the SWIG
documentation, such as from a web page or an issue. Renaming or removing the
anchor silently breaks it.""",
    epilog="""\
The anchors in index.html, Sections.html and the chapters listed in the
chapters file are compared with those in the same files where the current
branch left REVISION, that is at 'git merge-base REVISION HEAD'. The files are
read from the current directory, which must be Doc/Manual, so changes that are
not committed yet are checked too. The heading numbers and the form of the
headings make no difference. A chapter that is new is not checked.

An anchor that has gone is reported in one of two ways:
  renamed  A heading with the same text is still in the chapter, but with an
           anchor that is new. This is an error. Keep the old anchor as the
           id of the heading instead.
  removed  Any other anchor that has gone, such as the anchor of a heading or
           a chapter that was removed. This is a warning, as a section is
           sometimes removed deliberately, but it needs pointing out for
           review.

The commits compared are written to stdout first: HEAD, the commit REVISION
refers to and their merge base. The renamed and removed anchors follow on
stderr, then a summary line on stdout. When the environment variable
GITHUB_ACTIONS is true, as in a GitHub Actions workflow, each renamed and
removed anchor is also written as an annotation on the file for GitHub to show.

Exits 0 when no anchor was renamed, even if some were removed. Exits 1 when an
anchor was renamed or git fails, such as for a REVISION that does not exist.

Examples, run in Doc/Manual:
  python3 checkanchors.py                compare with master
  python3 checkanchors.py origin/master  compare with origin/master
  python3 checkanchors.py v4.5.1         compare with the v4.5.1 release""")
parser.add_argument("revision", metavar="REVISION", nargs="?", default="master",
                    help="the git revision to compare with, such as a branch, a tag or a commit (default: master)")
revision = parser.parse_args().revision
github = os.environ.get("GITHUB_ACTIONS") == "true"

def git(*args):
    try:
        return subprocess.run(["git"] + list(args), stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, universal_newlines=True, errors="replace").stdout
    except FileNotFoundError:
        sys.exit("Error: git not found, the anchor check compares the chapters with a git revision")
    except subprocess.CalledProcessError as e:
        sys.exit("Error: git %s failed: %s" % (" ".join(args), e.stderr.strip()))

heading = re.compile(r'<H([1-5])(?:\s+id="([^"]*)")?>\s*(?:<a\s+name="([^"]*)">)?(.*?)</H\1>', re.IGNORECASE)
aname = re.compile(r'<a\s+name="([^"]*)"', re.IGNORECASE)

def anchors(text):
    # Returns the anchors as a dict of anchor to (heading text or None, line number)
    found = {}
    for lineno, line in enumerate(text.splitlines(), 1):
        m = heading.search(line)
        if m:
            title = re.sub(r"<[^>]*>", "", m.group(4))
            title = re.sub(r"^[\d.]+\s+", "", " ".join(title.split()))
            anchor = m.group(2) or m.group(3)
            if anchor:
                found[anchor] = ("H%s %s" % (m.group(1), title), lineno)
        else:
            for name in aname.findall(line):
                found[name] = (None, lineno)
    return found

def chapters(text):
    return [c.strip() for c in text.splitlines() if c.strip() and not c.startswith("#")] + ["Sections.html", "index.html"]

head = git("rev-parse", "HEAD").strip()
revisioncommit = git("rev-parse", "--verify", revision + "^{commit}").strip()
base = git("merge-base", revisioncommit, head).strip()
prefix = git("rev-parse", "--show-prefix").strip()

# Say which commits are compared before reporting any problem, so that a log shows them whatever the outcome
print("Anchor check: HEAD is %s and %s is %s" % (head[:12], revision, revisioncommit[:12]))
print("Anchor check: comparing the anchors with their merge base %s %s" % (base[:12], git("log", "-1", "--format=%s", base).strip()), flush=True)

errors = []
warnings = []
compared = 0
for chapter in chapters(git("show", "%s:%schapters" % (base, prefix))):
    path = prefix + chapter
    try:
        old = anchors(git("show", "%s:%s" % (base, path)))
    except SystemExit:
        continue  # a chapter that is not in the base revision
    if not os.path.exists(chapter):
        warnings.append((path, None, "the chapter, with its %d anchors, has been removed" % len(old)))
        continue
    new = anchors(open(chapter, encoding="utf-8", errors="replace").read())
    compared += len(old)
    for anchor, (title, _) in sorted(old.items()):
        if anchor in new:
            continue
        renamed = [a for a, (t, _) in new.items() if title is not None and t == title and a not in old]
        if renamed:
            errors.append((path, new[renamed[0]][1], "anchor %s of heading '%s' has been renamed to %s" % (anchor, title[3:], renamed[0])))
        else:
            what = "of heading '%s' " % title[3:] if title else ""
            warnings.append((path, None, "anchor %s %shas been removed" % (anchor, what)))

for kind, items in (("warning", warnings), ("error", errors)):
    for path, line, message in items:
        if github:
            print("::%s file=%s%s::%s" % (kind, path, ",line=%d" % line if line else "", message), flush=True)
        sys.stderr.write("%s: %s: %s\n" % (kind.capitalize(), path + (":%d" % line if line else ""), message))

if errors:
    sys.stderr.write("Never rename an existing anchor as links to it from outside the documentation break, keep the old anchor.\n")
    sys.exit(1)

print("Anchor check: %d anchors compared, %d renamed, %d removed" % (compared, len(errors), len(warnings)))
