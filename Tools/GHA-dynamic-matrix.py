#!/usr/bin/env python3
import os
import platform
import yaml
import json
import re
import sys

# For GITHUB_XXX variables use, see:
# https://docs.github.com/en/actions/reference/workflows-and-actions/variables

def publish(results):
    with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
        fh.write('matrix=' + json.dumps(results) + '\n')

def filterFiles(all_files):
    event_name=os.environ.get('GITHUB_EVENT_NAME')
    # Only pull request pass files filter
    if event_name != 'pull_request':
        print('We are not a pull request')
        return True, None
    usedLanguages=[]
    ymlfile=re.sub(r'.*/(\.github/workflows/[^.]+\.yml)@.*', r'\1', os.environ['GITHUB_WORKFLOW_REF'])
    for f in all_files:
        skip=False
        if f == ymlfile:
            print('The calling yaml file changed')
            return True, None
        elif re.match(r'^CHANGES', f):
            skip=True
        elif re.match(r'^Doc/', f):
            skip=True
        elif re.match(r'^\.github/workflows/.*\.yml$', f):
            # Other YMAL files
            skip=True
        elif re.match(r'^Examples/test-suite/errors', f):
            m = 'ccache'
        elif re.match(r'^Examples/test-suite/schemerunme', f):
            m = 'guile'
        elif re.match(r'^Examples/test-suite/.*_.*\.i$', f):
            m = re.sub(r'^Examples/test-suite/([^_]+)_.*\.i$', r'\1', f)
        elif re.match(r'^Examples/test-suite/', f):
            m = re.sub(r'^Examples/test-suite/([^/]+)/.*', r'\1',f)
        elif re.match(r'^Examples/', f):
            m = re.sub(r'^Examples/([^/]+)/.*', r'\1',f)
        elif re.match(r'^Lib/', f):
            m = re.sub(r'^Lib/([^/]+)/.*', r'\1',f)
        elif re.match(r'^Source/Modules/.*\.cxx$', f):
            m = re.sub(r'^Source/Modules/([^.]+)\.cxx$', r'\1',f)
        elif re.match(r'^Tools/javascript/', f):
            m = 'javascript'
        elif re.match(r'^CCache/', f):
            # All the folder belong to CCache tests
            m = 'ccache'
        else:
            # File belong to
            print('File do not belong to any language:', f)
            return True, None
        if not skip:
            match m:
                case 'c'|'csharp'|'d'|'go'|'guile'|'java'|'javascript'|'lua'|'ocaml'|'octave'|'perl5'|'php'|'python'|'r'|'ruby'|'scilab'|'tcl'|'ccache':
                    if not m in usedLanguages:
                        print('File', f, ' use language', m);
                        usedLanguages.append(m)
                case _: # Unkown language, run all tests
                    print('File do not belong to any language:', f)
                    return True, None
    return False, usedLanguages

github_actions=os.environ.get('GITHUB_ACTIONS')
if github_actions != 'true':
    sys.stderr.write('To use by GitHub Actions\n')
    exit(1)

# Base matrix is passed from YML
base_matrix=yaml.safe_load(os.environ['MATRIX_BASE'])

# Generate with https://github.com/tj-actions/changed-files
with open('.github/outputs/all_changed_and_modified_files.json', 'r') as file:
    all_files = json.load(file)

use_all, usedLanguages = filterFiles(all_files)

if use_all:
    # Just pass the matrix as is
    print('Run all tests');
    publish(base_matrix)
else:
    results=[]
    for x in base_matrix:
        # A test can be marked to always runs!
        if 'ALWAYS_RUNS' in x and x['ALWAYS_RUNS'] != '':
            results.append(x)
        # CCache uses empty SWIGLANG
        elif x['SWIGLANG'] == '' and 'ccache' in usedLanguages:
            results.append(x)
        elif x['SWIGLANG'] in usedLanguages:
            results.append(x)
    # If there are no results, add the first test
    if len(results) == 0:
        results.append(base_matrix[0])
    print('Run ', len(results), ' tests for languages ', usedLanguages)
    publish(results)
