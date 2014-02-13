#!/usr/bin/env python

"""
Pandoc filter that changes pandoc default HTML output for codeblocks
to match SWIG's format:

    <div class="...">
      <pre>...</pre>
    </div>

"""

from pandocfilters import toJSONFilter, stringify, walk, RawBlock, Div, Str
import sys
import json
import re

global the_title

def html(x):
  return RawBlock('html', x)

SHELL = re.compile(r"\s*[$]")

def codeblocks(key, value, format, meta):
  if key == 'CodeBlock':
    [[id, classes, kvs], contents] = value
    if format == "html" or format == "html5":
      newcontents = [html('<pre>\n' + contents + '</pre>')]

      if contents.startswith("$"):
        classes.append("shell")

      if len(classes) == 0:
        classes.append("code")

      return Div([id, classes, kvs], newcontents)
  if key == 'Header':
    if value[0] == 1:
      global the_title
      the_title = stringify(value)
    value[1][0] = ""

def set_title(unMeta):
  global the_title
  unMeta["title"] = {"t": "MetaInlines", "c": [Str(the_title)]}

def __toJSONFilter(action):
  doc = json.loads(sys.stdin.read())
  if len(sys.argv) > 1:
    format = sys.argv[1]
  else:
    format = ""
  altered = walk(doc, action, format, doc[0]['unMeta'])
  set_title(altered[0]['unMeta'])
  json.dump(altered, sys.stdout)

if __name__ == "__main__":
  __toJSONFilter(codeblocks)
