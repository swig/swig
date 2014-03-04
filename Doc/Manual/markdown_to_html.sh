#!/bin/bash

if [ "$1" == "" ]; then
	echo "Usage: markdown_to_html <Language>"
	echo "-- Example: markdown_to_html Javascript"
else
	pandoc -f markdown -t json $1.md | ./pandoc_filter.py | pandoc -f json -t html -s --template pandoc_template.html -o $1.html
fi

