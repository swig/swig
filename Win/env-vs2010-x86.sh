# vs2010 32 bit builds on a 32 bit Windows install
# PATH is CYGWIN style
export PATH="/cygdrive/c/Program Files/Microsoft Visual Studio 10.0/VC/BIN:/cygdrive/c/Windows/Microsoft.NET/Framework64/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework64/v3.5:/cygdrive/c/Program Files/Microsoft Visual Studio 10.0/VC/VCPackages:/cygdrive/c/Program Files/Microsoft Visual Studio 10.0/Common7/IDE:/cygdrive/c/Program Files/Microsoft Visual Studio 10.0/Common7/Tools:/CYGDRIVE/C/Program Files/Microsoft SDKs/Windows/v7.0A/bin:/CYGDRIVE/C/Program Files/Microsoft SDKs/Windows/v7.0A/bin:/usr/bin:$PATH"

# Other environment variables are Windows style, only used by native CL.EXE and LINK.EXE
export INCLUDE='c:\Program Files\Microsoft Visual Studio 10.0\VC\INCLUDE;c:\Program Files\Microsoft Visual Studio 10.0\VC\ATLMFC\INCLUDE;C:\Program Files\Microsoft SDKs\Windows\v7.0A\include;'

export LIB='c:\Program Files\Microsoft Visual Studio 10.0\VC\LIB;c:\Program Files\Microsoft Visual Studio 10.0\VC\ATLMFC\LIB;C:\Program Files\Microsoft SDKs\Windows\v7.0A\lib;'

export LIBPATH='c:\Windows\Microsoft.NET\Framework\v4.0.30319;c:\Windows\Microsoft.NET\Framework\v3.5;c:\Program Files\Microsoft Visual Studio 10.0\VC\LIB;c:\Program Files\Microsoft Visual Studio 10.0\VC\ATLMFC\LIB;'

export VCINSTALLDIR='c:\Program Files\Microsoft Visual Studio 10.0\VC\'
