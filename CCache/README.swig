This directory contains a version of ccache. The initial version was based on ccache-2.4 plus 
debian patches 01-02, 04-12, see the debian/patches subdirectory. Changes have been made to
support cacheing the output from SWIG. The ability to cache c/c++ compiler output has been retained.

Additional features added are the CCACHE_VERBOSE and CCACHE_SWIG environment variables, see docs.
