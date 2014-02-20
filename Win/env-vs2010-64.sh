# VS2010 64 bit builds on a 64 bit Windows install
# PATH is CYGWIN style
export PATH="/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 10.0/VC/BIN/amd64:/cygdrive/c/Windows/Microsoft.NET/Framework64/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework64/v3.5:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 10.0/VC/VCPackages:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 10.0/Common7/IDE:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 10.0/Common7/Tools:/CYGDRIVE/C/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/bin/x64:/CYGDRIVE/C/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/bin:/usr/bin:$PATH"

# Other environment variables are Windows style, only used by native CL.EXE and LINK.EXE
export INCLUDE='c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\INCLUDE;c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\ATLMFC\INCLUDE;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\include;'

export LIB='c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\LIB\amd64;c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\ATLMFC\LIB\amd64;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\lib\x64;'

export LIBPATH='c:\Windows\Microsoft.NET\Framework64\v4.0.30319;c:\Windows\Microsoft.NET\Framework64\v3.5;c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\LIB\amd64;c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\ATLMFC\LIB\amd64;'

export VCINSTALLDIR='c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\'
