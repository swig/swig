#! /bin/sh
# Bootstrap the development environment
autoconf
(cd Source/DOH; autoconf)
(cd Tools; autoconf)
(cd Examples/GIFPlot; autoconf)
