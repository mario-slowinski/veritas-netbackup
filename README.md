# Scripts for Veritas Netbackup

* [nbdb_unload.awk](#nbdb_unload.awk) - search and update
* [drives-list.sh](#drives-list.sh) - list and compare installed and scanned tape drives

## nbdb_unload.awk - search and update

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

* Apply updates from sql file.

  ```bash
  LD_LIBRARY_PATH=/usr/openv/db/lib/ /usr/openv/db/bin/dbisqlc -c "CS=utf8;UID=dba;PWD=nbusql;ENG=NB_<masterservername>;DBN=NBDB;LINKS=tcpip(IP=127.0.0.1;PORT=13785)" <sqlfile>
  ```

## drives-list.sh - list and compare installed and scanned tape drives

* list already configured drives details

  ```bash
  ./drive-list.sh
  ```

* list already configured drives formated as tpconfig command, useful to configure drive on other media server

  ```bash
  ./drive-list.sh -c
  ```

* list scanned drives but not configured

  ```bash
  ./drive-list.sh -m
  ```
