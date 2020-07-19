#!/bin/bash
cd "$(dirname "$0")"
set -e

root_html_doc_dir='../Doc/Manual'
sphinx_src_dir='source/Manual'

mkdir -p $sphinx_src_dir

for html in $root_html_doc_dir/*.html
do
    echo converting $html
    html_base_name=$(basename $html)
    rst_base_name=${html_base_name/html/rst}
    rst=$sphinx_src_dir/$rst_base_name
    pandoc -o $rst $html
done

