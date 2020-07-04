#!/bin/awk

function join(arr,sep){
	output=arr[0]
	for(i=1;i<length(arr); i++) {
		output=output sep arr[i]
	}
	return output
}

$1~/[a-z]/ {
	slp=$1
	delete residence
	delete managed
	delete rl
	delete uf
	delete source
	delete window
} 
$1~/^[0-9]/ {
	residence[$1]=$2
	managed[$1]=$5
	source[$1]=$1
	rl[$1]=$6
	uf[$1]=$10
	window[$1]=$14
} 
$1~/^1$/ {
print "nbstl",slp,
	"-add",
	"-managed",join(managed,","),
	"-uf",join(uf,","),
	"-source",join(source,","),
	"-rl",join(rl,","),
	"-residence",join(residence,","),
	"-window",join(window,",")
}
