# Scripts for Veritas Netbackup

* [nbdb_unload](#nbdb_unload) - search and update
* [drives-list](#drives-list) - list and compare installed and scanned tape drives
* [oneliners](#oneliners)

--------------------------------------------------------------------------------

## nbdb_unload

* Match NBDB table name to dat file in  NBDB database dump from `nbdb_unload` command.

  * Unload NBDB contents to working directory.

    ```bash
    /usr/openb/db/bin/nbdb_unload *working_directory*
    ```

  * Find NBDB table dat file in *working_directory*/reload.sql

    * list all tables and dat files

      ```bash
      gawk -f nbdb_unload.gawk reload.sql
      ```

    * search for table using regex, i.e. EMM_Media

      ```bash
      gawk -f nbdb_unload.gawk -v table=EMM_Media reload.sql
      gawk -f nbdb_unload.gawk -v table=EMM_Media$ reload.sql
      ```

* Generate shell commands batch

  * Generate batch to add servers

    ```bash
    gawk -f nbdb_unload.gawk -v table=EMM_Machine -v generate=cmd 770.dat
    ```

  * Generate batch to add tapes

    ```bash
    gawk -f nbdb_unload.gawk -v table=EMM_MediaPool -v generate=cmd 778.dat
    ```

  * Generate batch to add tape pools

    * assign pool numbers to pool names, copy and paste output into shell session

      ```bash
      vmpool -list_all -bx | gawk 'BEGIN{print "unset pools; declare -A pools"} $2~/^[0-9]+$/ {print "pools["$1"]="$2";"}'
      ```

    * generate vmadd batch

      ```bash
      gawk -f nbdb_unload.gawk -v table=EMM_Media -v generate=cmd 775.dat
      ```

* Update NBDB directly using prepared SQL file

  * Generate gawk script for selected table (no regex is allowed here) i.e. EMM_Media

    ```bash
    gawk -f nbdb_unload.gawk -v table=EMM_Media -v key=MediaId -v generate=sql reload.sql > EMM_Media.gawk
    ```

  * Remove unwanted columns from **SET** section in generated script. Don't forget to remove coma from last column before WHERE.

  * Create SQL script to update NBDB table, i.e. EMM_Media with dat file found in 1st section

    ```bash
    gawk -f EMM_Media.gawk 775.dat > EMM_Media.sql
    ```

  * Stop all netbackup services.
    
  * Start NBDB service only with `nbdbms_start_server`.

  * Replace *[masterservername]* with name of your master server and run `dbisqlc` to apply updates from *[sqlfile]*.

    ```bash
    LD_LIBRARY_PATH=/usr/openv/db/lib/ /usr/openv/db/bin/dbisqlc -c "CS=utf8;UID=dba;PWD=nbusql;ENG=NB_[masterservername];DBN=NBDB;LINKS=tcpip(IP=127.0.0.1;PORT=13785)" [sqlfile]
    ```

--------------------------------------------------------------------------------

## drives-list

List and compare installed and scanned tape drives. Useful to configure tape drives on new media server with cuurent configuration output from already configured media server.

* list already configured drives details, run this on already configured media server and copy ouput to the new one

  ```bash
  ./drive-list.sh
  ```

* combine already configured drives list with the ones scanned and format output as tpconfig commands list

  ```bash
  ./drive-list.sh -c -i <output from configured media server>
  ```

* list drives scanned but not configured

  ```bash
  ./drive-list.sh -m
  ```

--------------------------------------------------------------------------------

## oneliners

* activate/deactivate policy as set in snapshot

  ```bash
  cp /usr/openv/netbackup/db/class /usr/openv/netbackup/class-snapshot-`date '+%Y%m%d'`
  for FILE in `find /usr/openv/netbackup/db/class-snapshot-`date '+%Y%m%d'` -maxdepth 2 -type f -name info`; do POLICY=`dirname ${FILE}`; echo "bpplinfo -set ${POLICY##*/} `sed -n '/^ACTIVE/{s/ACTIVE 0/-active/;s/ACTIVE 1/-inactive/;p}' ${FILE}`"; done
  ```
