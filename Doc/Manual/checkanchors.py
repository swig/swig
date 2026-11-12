#!/usr/bin/python3

# Check that no existing anchor in the manual has been renamed or removed.
#
# An anchor, the id of a heading such as <H2 id="Python_nn25"> or an <a name="...">, can be the target of a link from
# outside the SWIG documentation, which renaming or removing the anchor silently breaks. The anchors in the chapters
# are compared with those where the current branch left the given git revision, master by default:
#  - the anchor of a heading that is still there with the same text, but a new anchor, has been renamed: an error
#  - any other anchor that has gone, such as the anchor of a heading that was removed: a warning
#
# Usage: checkanchors.py [revision]

import os
import re
import subprocess
import sys

revision = sys.argv[1] if len(sys.argv) > 1 else "master"
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
