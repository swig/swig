#######################################################################
# This script fixups the name of functions exported by a DLL. 
# If you export a C/C++ function using _stdcall calling convention the function is  exported  as _fx@n 
#  where
#            fx is the name of the function
#           n is the size of arguments passed on the stack.
######################################################################
#Input:
#	 1) the output a dumpbin dllname / exports - it is the list of the exported functions by the dll 
#    2) a .pas file or wildcard that import functions from the DLL
#
#Output:
#        none
#
#Description:
#
#    1) the list of exported functions is examined in order to detect that function'names that are decorated by the __stcall convention
#    2) the .pas files are processed, if they contain  functions declared as external and contained in the list of the above point the functions
#       name are decorated in order to match to the name exported by the DLL
#        
#  e.g: function GDALOpen ... name 'GDALOpen' becomes function GDALOpen ... name '_GDALOpen@2'
#
#        the .Pas files are backuped 
#       
#
# Written By Stefano Moratto
#            stefano.moratto@gmail.com

use File::Copy;

sub replace_name 
{
  $filename = @_[0];
  $external = @_[2];
  $original = @_[1];	
  $bakfile = $filename;
  $bakfile .= '.bak';
  my $line = "";
  
  print "Replace $filename, $bakfile $external -> $original \n";
  copy("$filename", "$bakfile") or die "File cannot be copied.";
  
  open(F1,"$bakfile") or die "Unable to open map file $bakfile\n";
  open(F2,">$filename") or die "Unable to open map file $bakfile\n";
  $exp = "name \'\Q$external\E\'";
  
  $repl = "name \'\Q$original\E\'";

  #print "!!$exp\n";

  while ($line = <F1>)
  {

	chomp($line);

	if ($line =~ /$exp/ ) {
	
		$line1 = $line;
		$line1 =~ s/$exp/$repl/ ; 
		
	   # print "***$line -> $line1\n";
		
		print F2 "$line1\n";
	}
	else {
	   print F2 "$line\n";
	}
  }
  
  close(F1);
  close(F2);
  
}

sub replace_name_all 
{
  my ($filename, $mappings) = @_;
  #@mappings = @@_[1];
  $bakfile = $filename;
  $bakfile .= '.bak';
  my $line = "";
  
  print "Replace in $filename ( backup in $bakfile)\n";
  copy("$filename", "$bakfile") or die "File cannot be copied.";
  
  open(F1,"$bakfile") or die "Unable to open map file $bakfile\n";
  open(F2,">$filename") or die "Unable to open map file $bakfile\n";
  
  while ($line = <F1>)
  {

	chomp($line);

	my $m = 0;

	foreach $p (@$mappings) {
	 
		$external  = $$p[0] ;
	 	$original = $$p[1] ;
	
	 #	print "$external -> $original \n";

	  	$exp = "name \'\Q$external\E\'";
	    $repl = "name \'$original\'";

		if ($line =~ /$exp/ ) {
		
			$line1 = $line;
			$line1 =~ s/$exp/$repl/ ; 
			
		    print "***$line -> $line1\n";
			
			$m = 1;
			
			print F2 "$line1\n";
		}
		
	  } 
	  
	  if ($m == 0) {
		   print F2 "$line\n";
		}
	  
  }
  
  close(F1);
  close(F2);
  
}

print "Extract function names declared with __stdcall convection that are exported by a DLL\n";

#print "|@ARGV\n";
#print $#ARGV+1 ;


$pasmak='*.pas';

if (($#ARGV+1) < 2) { die "Please, specify input file pas_file\n"; }

if (($#ARGV+1) >=2 ) 
{ $xx = ';'; }

$mapfile = $ARGV[0];
$pasmask=$ARGV[1];
print "$mapfile \n";

print "fixup of : $mapfile into \n";
@pasfiles = glob($pasmask);
foreach $pasfile (@pasfiles) {
  print $pasfile . "\n";
}

open(MAP,"$mapfile") or die "Unable to open map file $mapfile\n";

$state = 0;

@vv = (); # mapping of function name

while ($line = <MAP>)
{

  #print $line;
	chomp($line);
  
	if ($line =~ /\s*ordinal\s*hint\s*RVA\s*name/ ) {
		#print "Begin of functions\n";
		$state = 1;
	}
	
	if ($line =~ /\s*entry point at/ ) {
#		print "End of functions\n";
		$state = 2;
	}

	if ($state == 1) {
	#	print "$line \n";
		@exports = split (/\s+/, $line);
	
	# foreach $i (@exports ){	print "$i|";}
		#print "$exports[1] $exports[4]:\n";
		#if ($exports[1] =~/\d+/ ) {
		if ($exports[1] =~ /\d+/  && $exports[4] =~ /_([a-z]|[A-Z]|[0-9])+@\d+/) {
		
		#if ($exports[1] =~/\d+/  && $exports[3] !~/\w/) {
		
			
			
			$original = $exports[4];
			$exported = $original;
			$exported =~ s/_//;
			$exported =~ s/@\w+//;
#			print "$original->$exported\n";
		#	print DEF "\t $xx $exported=$original\n";
					
			push(@vv, [$exported, $original]);
						
		}
	
	}
	
	
}

close(MAP); 

foreach $pasfile (@pasfiles) {
  replace_name_all($pasfile, \@vv);

}
foreach $p (@vv) {
	my $exp = $$p[0] ;
	my $orig = $$p[1] ;

   # print "$orig <-> $exp \n";
 			#	replace_name( $pasfile, $original, $exported );
}