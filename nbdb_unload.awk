#!/bin/awk

function EMM_Machine() {
	machinetype[3]="master"
	machinetype[1]="media"
	machinetype[2]="ndmp"
	machinetype[5]="cluster"
	machinetype[6]="server"
	machinetype[8]="client"
	machinetype[14]="appliance"
	operatingsystem[5]="rs6000"
	operatingsystem[16]="linux"
	if($14 > 0) { netbackupversion="-netbackupversion "substr($14,1,1)"."substr($14,2,1)"."substr($14,3,1) }
	if($8 == 3) { masterserver=$4 } if($8 == 5) { masterserver=$4 }
	if($12) {
		print "nbemmcmd",
			"-addhost",
			"-machinename",$4,
			"-machinetype",machinetype[$8],
			"-operatingsystem",operatingsystem[$12],
			netbackupversion,
			"- masterserver",masterserver
	}
}
function EMM_MediaPool() {
	print "vmpool",
		"-create -pn",$3,
		"-description \""$4"\""
	switch($10) { 
		case 1: { print "vmpool -set_scratch",$3; break }
		case 2: { print "vmpool -set_catalog_backup",$3; break }
	}
}
function EMM_Media() {
	split($8,mediatype," ")
	print "vmadd",
		"-m",$4,
		"-mt",$7,
		"-barcode",$17,
		"-d \""$16"\"",
		"-mm",$35,
		"-p","${pools["$51"]}"
}
BEGIN {
	found=0
	switch(generate) {
		case "cmd": { 
			FS=","; 
		} break;
		default: {if(table=="") { table=".*" }} break;
	}
}
{
	switch(generate) {
		case "cmd": { gsub("'",""); @table() } break
		case "sql": {
			gsub("\"","")
			if($1=="CREATE" && $2=="TABLE" && $3=="EMM_MAIN."table) {
				column=1
			}
			if(column >0 && ($1==",CONSTRAINT" || $1==")")) { 
				column=0 
			}
			if(column > 0 && $1!="CREATE") {
				gsub(",","",$1)
				nbdbtable[column++]=$1
			}
		} break
		default: {
			gsub("\"","")
			if($1=="INPUT" && $2=="INTO" && $3~table) {
				found=1
				nbdbtable=$3
			}
			if($1=="FROM" && $2~".dat" && found) {
				found=0
				print nbdbtable,"->",$2
			}
		} break
	}
}
END {
	switch(generate) {
		case "sql": {
			if(length(nbdbtable) == 0) {
				print "SQL table",table,"not found!"
				exit
			}
			if(table=="" || key=="") {
				print "Please run script with required parameters"
				print "awk -f nbdb_unload.awk -v table=<EMM_table_name> -v key=<EMM_table_column_name> -v generate=1 reload.sql"
				exit
			}
			print "#!/bin/awk"
			print ""
			print "BEGIN {"
			print "\tFS=\",\""
			for(column=1; column<=length(nbdbtable); column++) {
				print "\t"table"[\""nbdbtable[column]"\"]="column
			}
			print "}"
			print ""
			print "{"
			print "\tprint \"\""
			print "\ttransid=$"table"[\""key"\"]; gsub(\"'\",\"\",transid)"
			print "\tprint \"BEGIN TRANSACTION \"transid\";\""
			print "\tprint \"UPDATE EMM_MAIN."table"\""
			print "\tprint \"SET\""
			for(column=1; column<length(nbdbtable); column++) {
				print "\tprint \"     "nbdbtable[column]"\t= \"$"table"[\""nbdbtable[column]"\"]\",\""
			}
			print "\tprint \"     "nbdbtable[column]"\t= \"$"table"[\""nbdbtable[column]"\"]"
			print "\tprint \"WHERE EMM_MAIN."table"."key" = \"$"table"[\""key"\"]\";\""
			print "\tprint \"COMMIT TRANSACTION \"transid\";\""
			print "\tprint \"\""
			print "}"
			print ""
			print "END {"
			print "\tprint \"\""
			print "\tprint \"-- stop netbackup services and start NBDB only with nbdbms_start_server\""
			print "\tprint \"-- Save output to sqlfile and run below command replacing [masterservername]\""
			print "\tprint \"-- LD_LIBRARY_PATH=/usr/openv/db/lib/ /usr/openv/db/bin/dbisqlc -c \\\"CS=utf8;UID=dba;PWD=nbusql;ENG=NB_[masterservername];DBN=NBDB;LINKS=tcpip(IP=127.0.0.1;PORT=13785)\\\" <sqlfile>\""
			print "}"
		}
	}
}
