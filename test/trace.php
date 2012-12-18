<?php
declare(ticks=1);
function above_0($a)
{
	if($a>0){
		echo ">0";
	}
	else{
		echo "<0";
	}
}

function above_10($a)
{
	if($a>10){
		echo ">10";
	}
	else{
		echo "<10";
	}
}

function ret_ord( $c )
{
	if($c=="u")
	{
		echo "error";
	}
	else{
		echo "ok";
	}

	if($c=='a')
	{
		echo "a";
	}
	else{
		echo "not a ";
	}


	echo $c;
	above_10($c);
	above_0($c);
	return ord( $c );
}
function x()
{
	echo 2;
}

#$data=file('test.data');
#$data=$argv[1];
#fore$ach($data as $str){
$str=$argv[1];
foreach ( str_split( $str ) as $char )
{
	echo "\n";
	above_0($char);
	echo $char, ": ", ret_ord( $char ), "\n";
}
#}
?>

