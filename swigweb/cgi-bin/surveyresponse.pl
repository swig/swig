#!/usr/bin/perl

# This is a CGI script which takes the input from the simple survey submitted in 
# survey.html. The user's intended languages and operating systems are stored in 
# simple comma separated value files.

use CGI;
$q = new CGI;

# Start the response web page
print "Content-type:text/html\n\n";
print <<EndHTML;
<html><head><title>SWIG Survey Submission</title></head>
<body>
<p/>
<table> <tr>
<td bgcolor="#000000" align=center><font color="#ffffff"><b>SWIG Survey Submission</b></font></td>
</tr> </table>

EndHTML


# Extract all the variables out of the response
$remoteHost = $ENV{'REMOTE_HOST'};
$remoteAddr = $ENV{'REMOTE_ADDR'};
$ipAddress = ($remoteHost == '') ? $remoteAddr : $remoteHost;

$langChicken    = $q->param('langChicken');
$langCSharp     = $q->param('langCSharp');
$langGuile      = $q->param('langGuile');
$langJava       = $q->param('langJava');
$langMzscheme   = $q->param('langMzscheme');
$langOcaml      = $q->param('langOcaml');
$langPerl       = $q->param('langPerl');
$langPhp        = $q->param('langPhp');
$langPike       = $q->param('langPike');
$langPython     = $q->param('langPython');
$langRuby       = $q->param('langRuby');
$langSexp       = $q->param('langSexp');
$langTcl        = $q->param('langTcl');
$langXml        = $q->param('langXml');
$langSpareLang1 = $q->param('langSpareLang1');
$langSpareLang2 = $q->param('langSpareLang2');
$langSpareLang3 = $q->param('langSpareLang3');
$langOtherLang  = $q->param('langOtherLang');

$namedLanguage  = $q->param('namedLanguage');

$osBSD          = $q->param('osBSD');
$osHPUX         = $q->param('osHPUX');
$osLinux        = $q->param('osLinux');
$osMacOSX       = $q->param('osMacOSX');
$osSolaris      = $q->param('osSolaris');
$osWindows      = $q->param('osWindows');
$osOtherOS      = $q->param('osOtherOS');

$namedOS        = $q->param('namedOS');

# Get log date
($seconds, $minutes, $hours, $day_of_month, $month, $year, $wday, $yday, $isdst) = gmtime;
$logDate = sprintf("%04d/%02d/%02d %02d:%02d", $year+1900, $month+1, $day_of_month, $hours, $minutes);

# Create new file each month
$fileName = sprintf("../survey/swigsurvey-%04d-%02d.csv", $year+1900, $month+1);

if (!-e $fileName) {
    create_file($fileName);
}

# Open file for appending and lock it to prevent concurrent access
open(fileOUT, ">>$fileName") or construct_thankyou_page_and_exit(); # We can't log the info if we can't open the file, quietly give up.
flock(fileOUT, 2);
seek(fileOUT, 0, 2);

# Dump all the surveyed data to file in comma separated value (CSV) format
print fileOUT "$logDate,$ipAddress,";
print fileOUT "$langChicken,$langCSharp,$langGuile,$langJava,$langMzscheme,$langOcaml,$langPerl,$langPhp,$langPike,$langPython,$langRuby,$langSexp,$langTcl,$langXml,$langSpareLang1,$langSpareLang2,$langSpareLang3,$langOtherLang,$namedLanguage,";
print fileOUT "$osBSD,$osHPUX,$osLinux,$osMacOSX,$osSolaris,$osWindows,$osSpareOS1,$osSpareOS2,$osSpareOS3,$osOtherOS,$namedOS";
print fileOUT "\n";
close(fileOUT);

# Create html page response
construct_thankyou_page_and_exit();

sub create_file($)
{
    my($fileToCreate) = @_;

    open(fileOUT, ">$fileToCreate") or construct_thankyou_page_and_exit(); # We can't log the info if we can't create the file, quietly give up.

    # Generate field heading names
    print fileOUT "LogDate,IPAddress,";
    print fileOUT "Chicken,CSharp,Guile,Java,Mzscheme,Ocaml,Perl,Php,Pike,Python,Ruby,Sexp,Tcl,Xml,SpareLang1,SpareLang2,SpareLang3,OtherLang,NamedLanguage,";
    print fileOUT "BSD,HPUX,Linux,MacOSX,Solaris,Windows,SpareOS1,SpareOS2,SpareOS3,OtherOS,NamedOS";
    print fileOUT "\n";
}

sub construct_thankyou_page_and_exit
{
    print <<EndHTML;

    Thank you for taking the time to fill out the survey. Please continue to the 
    <a href="../download.html">Download area</a> or return to the <a href="../index.html">SWIG home</a> page.
    </body></html>

EndHTML
    exit;
}







