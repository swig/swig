<?php

$myfile = fopen("test_New14.log", "r") or die("Unable to open file!");
echo "asd\n";
$total = 0;
$passed = 0;
$flag = false;
$i = 1;
$pass_case = "";
$wrong_case = "";
while(!feof($myfile)) {
	//$line = fgets($myfile);
	while($line = fgets($myfile)) {
		//echo $line;
	   $array = explode("checking php testcase ",$line);
	   $ite = 1;
	   foreach($array as $key) {
	   	if($ite == 2) {
	   	     $total++;
		   	 if ($flag) {
		   	 	$passed++;
		   	 	$pass_case = $pass_case . "\n" . $key;
		   	 }
	         $flag = true;
	   	}
	   	$ite++;
	   }
	   if ($ite == 2)
	   	  $flag = false;
	   //$line = fgets($myfile);
	   $i++;
	   //if($i==100)
	   //break;
	}
	//break;
}

print "Total Test Cases = " . $total . "\n";
print "Passed Test Cases = " . $passed . "\n";
print "Not passed Test Cases = " . ($total-$passed) . "\n";
echo "assadd\n";

?>