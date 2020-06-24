#!/bin/awk

BEGIN {
	found=0
	if(table=="") { table=".*" }
}
{
if(!generate) {
	gsub("\"","")
	if($1=="INPUT" && $2=="INTO" && $3~table) {
		found=1
		nbdbtable=$3
	}
	if($1=="FROM" && $2~".dat" && found) {
		found=0
		print nbdbtable,"->",$2
	}
}
else {
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
}
}
END {
	if(generate) {
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
        	print "\tprint \"BEGIN TRANSACTION \"$"table"[\""key"\"]\";\""
        	print "\tprint \"UPDATE EMM_MAIN."table"\""
		print "\tprint \"SET\""
		for(column=1; column<length(nbdbtable); column++) {
        		print "\tprint \"     "nbdbtable[column]"\t= \"$"table"[\""nbdbtable[column]"\"]\",\""
		}
        	print "\tprint \"     "nbdbtable[column]"\t= \"$"table"[\""nbdbtable[column]"\"]"
		print "\tprint \"WHERE EMM_MAIN."table"."key" = \"$"table"[\""key"\"]\";\""
        	print "\tprint \"COMMIT TRANSACTION \"$"table"[\""key"\"]\";\""
        	print "\tprint \"\""
		print "}"
		print ""
		print "END {"
		print "\tprint \"\""
		print "\tprint \"-- stop netbackup services and start NBDB only with nbdbms_start_server\""
		print "\tprint \"-- Save output to sqlfile and run below command replacing <masterservername>\""
		print "\tprint \"-- LD_LIBRARY_PATH=/usr/openv/db/lib/ /usr/openv/db/bin/dbisqlc -c \\\"CS=utf8;UID=dba;PWD=nbusql;ENG=NB_<masterservername>;DBN=NBDB;LINKS=tcpip(IP=127.0.0.1;PORT=13785)\\\" <sqlfile>\""
		print "}"
	}
}
