# Scripts for Veritas Netbackup

* [nbdb_unload](#nbdb_unload) - search and update
* [drives-list](#drives-list) - list and compare installed and scanned tape drives

## nbdb_unload

Search and update NBDB database based on NBDB contents exported with `nbdb_unload` command.

* Unload NBDB contents to working directory.

  ```bash
  /usr/openb/db/bin/nbdb_unload *working_directory*
  ```

* Find NBDB table dat file in *working_directory*/reload.sql

  * list all tables and dat files

    ```bash
    awk -f nbdb_unload.awk reload.sql
    ```

  * search for table using regex, i.e. EMM_Media

    ```bash
    awk -f nbdb_unload.awk -v table=EMM_Media reload.sql
    awk -f nbdb_unload.awk -v table=EMM_Media$ reload.sql
    ```

* Generate awk script for selected table (no regex is allowed here) i.e. EMM_Media

  ```bash
  awk -f nbdb_unload.awk -v table=EMM_Media -v key=MediaId -v generate=1 reload.sql > EMM_Media.awk
  ```

* Remove unwanted columns from **SET** section in generated script. Don't forget to remove coma from last column before WHERE.

* Create SQL script to update NBDB table, i.e. EMM_Media with dat file found in 1st section

  ```bash
  awk -f EMM_Media.awk 775.dat > EMM_Media.sql
  ```

* Stop all netbackup services.
  
* Start NBDB service only with `nbdbms_start_server`.

* Replace *[masterservername]* with name of your master server and run `dbisqlc` to apply updates from *[sqlfile]*.

  ```bash
  LD_LIBRARY_PATH=/usr/openv/db/lib/ /usr/openv/db/bin/dbisqlc -c "CS=utf8;UID=dba;PWD=nbusql;ENG=NB_[masterservername];DBN=NBDB;LINKS=tcpip(IP=127.0.0.1;PORT=13785)" [sqlfile]
  ```

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
