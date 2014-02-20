# VS2012 64 bit builds on a 64 bit Windows install
# PATH is CYGWIN style
export PATH="/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 11.0/Common7/IDE/CommonExtensions/Microsoft/TestWindow:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 11.0/VC/BIN/amd64:/cygdrive/c/Windows/Microsoft.NET/Framework64/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework64/v3.5:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 11.0/VC/VCPackages:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 11.0/Common7/IDE:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 11.0/Common7/Tools:/cygdrive/c/Program Files (x86)/Windows Kits/8.0/bin/x64:/cygdrive/c/Program Files (x86)/Windows Kits/8.0/bin/x86:/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v8.0A/bin/NETFX 4.0 Tools/x64:/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Bin/x64:/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v8.0A/bin/NETFX 4.0 Tools:/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Bin:/usr/bin:$PATH"

# Other environment variables are Windows style, only used by native CL.EXE and LINK.EXE
export INCLUDE='C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\INCLUDE;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\ATLMFC\INCLUDE;C:\Program Files (x86)\Windows Kits\8.0\include\shared;C:\Program Files (x86)\Windows Kits\8.0\include\um;C:\Program Files (x86)\Windows Kits\8.0\include\winrt;'

export LIB='C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\LIB\amd64;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\ATLMFC\LIB\amd64;C:\Program Files (x86)\Windows Kits\8.0\lib\win8\um\x64;'

export LIBPATH='C:\Windows\Microsoft.NET\Framework64\v4.0.30319;C:\Windows\Microsoft.NET\Framework64\v3.5;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\LIB\amd64;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\ATLMFC\LIB\amd64;C:\Program Files (x86)\Windows Kits\8.0\References\CommonConfiguration\Neutral;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.0\ExtensionSDKs\Microsoft.VCLibs\11.0\References\CommonConfiguration\neutral;'

export VCINSTALLDIR='C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\'
