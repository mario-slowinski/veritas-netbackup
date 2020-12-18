#!/bin/awk

BEGIN {
	print "/usr/openv/volmgr/bin/scan 2>&1 | awk -f configDrives.awk"
	print "\trobnum=<robot number>"
	print "\trobpath=<robot path>"
	print "\tdrindex=<starting drive index>"
	print "\tname=<name prefix>"
	print "\tdrtype=[hcart2|hcart]"
	drtype="hcart2"
}

{
	gsub(/"/,"")
	if($1=="Device" && $2=="Name") {
		path=$4
	}
	if($1=="Device" && $2=="Identifier:") {
		serial=$5
	}
	# if robpath given as parameter == robot path in scan output
	if(robpath==path && $1=="Drive" && $3=="Serial" && $4=="Number") {
		# robsrive[drindex]=serial
		robdrive[$2]=$6
	}
}
# for the last element in drive description
$1~/Reason/ {
	if(serial"@path0" in drive) {
		drive[serial"@path1"]=path
	}
	else {
		drive[serial"@path0"]=path
	}
}

END {
	print ""
	print "PATH=${PATH}:/usr/openv/volmgr/bin; export PATH"
	print "tpconfig -add -robot",
		robnum,
		"-robtype TLD",
		"-robpath",robpath
	print ""
	--drindex
	#use below instead of 'for(robdrnum in robdrive)' for sorting purpose
	for(robdrnumi=1; robdrnum<length(robdrive); robdrnum++) {
		if(robdrive[robdrnum]"@path0" in drive) {
			printf "%s %s %s %s %d %s %s %d %s %s%02d %s %d %s %s\n",
				"tpconfig -add -drive",
				"-type",drtype,
				"-robot",robnum,
				"-robtype TLD",
				"-robdrnum",robdrnum,
				"-asciiname",name,robdrnum,
				"-index",drindex+robdrnum,
				"-path",drive[robdrive[robdrnum]"@path0"]
		}
		if(robdrive[robdrnum]"@path1" in drive) {
			printf "%s %s %s%02d %s %s\n",
				"tpconfig -add -drpath",
				"-asciiname",name,robdrnum,
				"-path",drive[robdrive[robdrnum]"@path1"]
		}
	}
}
