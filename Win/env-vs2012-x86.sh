# VS2012 32 bit builds on a 32 bit Windows install
# PATH is CYGWIN style
export PATH="/cygdrive/c/Program Files/Microsoft Visual Studio 11.0/Common7/IDE/CommonExtensions/Microsoft/TestWindow:/cygdrive/c/Program Files/Microsoft Visual Studio 11.0/Common7/IDE/:/cygdrive/c/Program Files/Microsoft Visual Studio 11.0/VC/BIN:/cygdrive/c/Program Files/Microsoft Visual Studio 11.0/Common7/Tools:/cygdrive/c/Windows/Microsoft.NET/Framework/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework/v3.5:/cygdrive/c/Program Files/Microsoft Visual Studio 11.0/VC/VCPackages:/cygdrive/c/Program Files/Windows Kits/8.0/bin/x86:/cygdrive/c/Program Files/Microsoft SDKs/Windows/v8.0A/bin/NETFX 4.0 Tools:/cygdrive/c/Program Files/Microsoft SDKs/Windows/v7.0A/bin/:/usr/bin:$PATH"

# Other environment variables are Windows style, only used by native CL.EXE and LINK.EXE
export INCLUDE='C:\Program Files\Microsoft Visual Studio 11.0\VC\INCLUDE;C:\Program Files\Microsoft Visual Studio 11.0\VC\ATLMFC\INCLUDE;C:\Program Files\Windows Kits\8.0\include\shared;C:\Program Files\Windows Kits\8.0\include\um;C:\Program Files\Windows Kits\8.0\include\winrt;'

export LIB='C:\Program Files\Microsoft Visual Studio 11.0\VC\LIB;C:\Program Files\Microsoft Visual Studio 11.0\VC\ATLMFC\LIB;C:\Program Files\Windows Kits\8.0\lib\win8\um\x86;'

export LIBPATH='C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Program Files\Microsoft Visual Studio 11.0\VC\LIB;C:\Program Files\Microsoft Visual Studio 11.0\VC\ATLMFC\LIB;C:\Program Files\Windows Kits\8.0\References\CommonConfiguration\Neutral;C:\Program Files\Microsoft SDKs\Windows\v8.0\ExtensionSDKs\Microsoft.VCLibs\11.0\References\CommonConfiguration\neutral;'

export VCINSTALLDIR='C:\Program Files\Microsoft Visual Studio 11.0\VC\'
