# Swig Documentation

Swig used to use html files for documentation. It moved to sphinx and rst
because handcrafted html files are harder to maintain.

## How to build docs

Here is how to setup environment and build docs:

* Install python3: `sudo apt-get install python3 python3-pip`
* Install dependencies: `pip3 install -r requirements.txt`
* Build html: `make html`
* Open `build/html/index.html` in a browser to browse docs

You might have to `make clean` if there are issues with generated html.

## How to write docs

Sphinx is fairly simple system to use. It uses a markup called restructured
text (rst) to write docs. You can read the following tutorials to get started
with rst and sphinx:

* Learn RST in y minutes: https://learnxinyminutes.com/docs/rst/
* reStructuredText Primer: https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html
* Sphinx Quickstart: https://www.sphinx-doc.org/en/master/usage/quickstart.html
* Getting started with Sphinx: https://docs.readthedocs.io/en/stable/intro/getting-started-with-sphinx.html
* How to link/reference b/w docs: https://www.sphinx-doc.org/en/master/usage/restructuredtext/roles.html#ref-role
