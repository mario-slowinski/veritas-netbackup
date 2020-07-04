#!/bin/awk

BEGIN {
	print "bppllist | policy-update.awk oldstu= newstu="
}

$1~/^CLASS$/ {policy=$2}
$1~/^RES$/ {
	if($2==oldstu) {
		print "bpplinfo",policy,"-modify -residence",newstu
	}
}
$1~/^SCHED$/ {sched=$2}
$1~/^SCHEDRES$/ {
	if($2==oldstu) {
		print "bpplschedrep",policy,sched,"-residence",newstu
	}
}
