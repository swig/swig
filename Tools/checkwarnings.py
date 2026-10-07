#!/usr/bin/env python3
#
# Check that the warning numbers SWIG defines and the warning numbers the manual
# documents are the same set.
#
# Nothing else checks this, so a new warning number can be added to swigwarn.h and
# never reach Doc/Manual/Warnings.html, which is how several numbers came to be
# missing from the list.
#
# Only presence is checked, not the message text.  Comparing the documented text
# against the format strings in the source cannot be done reliably: many messages
# are assembled at run time, some reach Swig_warning through a wrapper that takes
# the number as a variable, and the manual writes a variable part as <em>name</em>
# where the source writes %s.  That comparison is better done by hand.
#
# Run Tools/checkwarnings.py --help for usage.
# Exits non-zero and lists the differences if the two sets do not match.

import argparse
import os
import re
import sys

# Exemptions, each a dictionary keyed by the warning number, an int, with the reason
# it is exempt as the value, a string.  The reason is not printed, it is there to say
# why the entry was added.  For example:
#
#   UNDOCUMENTED_OK = {
#       720: "no longer issued but still named by -w720 in the scilab examples",
#   }
#
# Add an entry only for a number that is deliberately in one file and not the other,
# rather than to silence the check.

# Numbers which are deliberately defined in swigwarn.h but not documented in Warnings.html.
UNDOCUMENTED_OK = {
}

# Numbers which are deliberately documented in Warnings.html but not defined in swigwarn.h.
UNDEFINED_OK = {
}


def defined_numbers(header):
    """Warning numbers with a live #define in swigwarn.h.

    A retired number is left in place as a comment, so only match a #define
    which actually starts the line.
    """
    numbers = {}
    with open(header) as f:
        for line in f:
            match = re.match(r"\s*#define\s+(WARN_\w+)\s+(\d+)", line)
            if match:
                number = int(match.group(2))
                # WARN_NONE is the "no warning" sentinel rather than a warning.
                if number != 0:
                    numbers[number] = match.group(1)
    return numbers


def documented_numbers(manual):
    """Warning numbers with a list entry in Warnings.html.

    Most entries end the number with a full stop, the Doxygen ones with a colon.
    An entry inside an HTML comment is not part of the rendered list, so comments
    are stripped first - a retired entry is kept commented out for reference.
    """
    with open(manual) as f:
        text = re.sub(r"<!--.*?-->", "", f.read(), flags=re.DOTALL)
    return set(int(n) for n in re.findall(r"<li>(\d+)[.:]", text))


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check that the warning numbers defined in Source/Include/swigwarn.h and "
                    "the warning numbers documented in Doc/Manual/Warnings.html are the same set.",
        epilog="Only presence is checked, not the message text. Exits 0 when the two sets match, "
               "1 when they differ and 2 when a file cannot be found.")
    parser.add_argument("sourcedir", nargs="?", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."),
                        help="the SWIG source directory to check (default: the one this script is in)")
    parser.add_argument("-q", "--quiet", action="store_true",
                        help="report differences only, without the summary line when the sets match")
    return parser.parse_args()


def main():
    args = parse_args()
    header = os.path.join(args.sourcedir, "Source", "Include", "swigwarn.h")
    manual = os.path.join(args.sourcedir, "Doc", "Manual", "Warnings.html")

    for path in (header, manual):
        if not os.path.isfile(path):
            sys.stderr.write("checkwarnings.py: cannot find %s\n" % path)
            return 2

    defined = defined_numbers(header)
    documented = documented_numbers(manual)

    undocumented = sorted(set(defined) - documented - set(UNDOCUMENTED_OK))
    undefined = sorted(documented - set(defined) - set(UNDEFINED_OK))

    for number in undocumented:
        print("%d (%s) is defined in swigwarn.h but not documented in Warnings.html" % (number, defined[number]))
    for number in undefined:
        print("%d is documented in Warnings.html but not defined in swigwarn.h" % number)

    if undocumented or undefined:
        print("\n%d warning number(s) differ between swigwarn.h and Warnings.html" % (len(undocumented) + len(undefined)))
        return 1

    if not args.quiet:
        print("swigwarn.h and Warnings.html agree on %d warning numbers" % len(documented))
    return 0


if __name__ == "__main__":
    sys.exit(main())
