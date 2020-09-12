# Swig Documentation

Swig used to use html files for documentation. It moved to sphinx and rst
because handcrafted html files are harder to maintain.

## How to build docs

Here is how to setup environment and build docs:

* Install python3: `sudo apt-get install python3 python3-pip`
* Install dependencies: `pip install -r requirements.txt`
* Build html: `make html`
* Open `build/html/index.html` in a browser to browse docs

You might have to `make clean` if there are issues with generated html.