## Summary


Training environment for learning how to setup slony replication.

*I've got this setup and working now*, after reading the slony overview document from dalibo (https://public.dalibo.com/exports/conferences/_archives/_2011/201110_slony/pgconfeu_slony.pdf).

The last two things I've done

* set listen_addresses='*' in postgres.conf
* added final setup_slony_master_and_slave.sh (before i.e. below, I was only slarting the master slon process - hence the connectivity problems I was getting below )

```
~/projects/vagrant-pg96-slony $ cat setup_slony_master_and_slave.sh
. ~/.bash_profile
mkdir /tmp/master
cd /tmp/master
/usr/pgsql-9.6/bin/slonik /vagrant/init_master.slonik &
sleep 2
mkdir /tmp/slave
cd /tmp/slave
/usr/pgsql-9.6/bin/slonik /vagrant/init_slave.slonik &
sleep 2
cd /tmp/master
nohup slon slony_example "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" &
sleep 2
cd /tmp/slave
nohup slon slony_example "dbname=pgbenchslave  host=localhost port=5432 user=slonyrep password=changeme" &
```

Note: this is 99% scripted i.e. you should just need to type vagrant up, although I did need to start the master and slave slon processes manually i.e. for some reason the called embedded within the setup_slony_master_and_slave.sh are not working (maybe sort sort of missing env parameter with shell scripts call shell scripts) 


```
~/projects/vagrant-pg96-slony $ vagrant ssh
Last login: Fri Jan 22 17:17:25 2021
[pg96slony:vagrant:~] # pg
Last login: Fri Jan 22 17:17:39 UTC 2021
[pg96slony:postgres:~] #  PGPASSWORD=changeme psql -U slonyrep -h localhost -p 5432 -d pgbenchslave -c "select count(*) from pgbench_branches;"
 count
-------
     0
(1 row)

[pg96slony:postgres:~] # ps -ef|grep slon
postgres  3944  3895  0 17:19 pts/0    00:00:00 grep --color=auto slon
[pg96slony:postgres:~] # cat /tmp/setup_slony_master_and_slave.sh
. ~/.bash_profile
mkdir /tmp/master
cd /tmp/master
/usr/pgsql-9.6/bin/slonik /vagrant/init_master.slonik &
sleep 2
mkdir /tmp/slave
cd /tmp/slave
/usr/pgsql-9.6/bin/slonik /vagrant/init_slave.slonik &
sleep 2
cd /tmp/master
nohup slon slony_example "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" &
sleep 2
cd /tmp/slave
nohup slon slony_example "dbname=pgbenchslave  host=localhost port=5432 user=slonyrep password=changeme" &

[pg96slony:postgres:~] # cd /tmp/master
[pg96slony:postgres:/tmp/master] # lt
total 0
[pg96slony:postgres:/tmp/master] # cd /tmp/master
[pg96slony:postgres:/tmp/master] # nohup slon slony_example "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" &
[1] 3968
[pg96slony:postgres:/tmp/master] # nohup: ignoring input and appending output to ‘nohup.out’

[pg96slony:postgres:/tmp/master] # cd /tmp/slave
[pg96slony:postgres:/tmp/slave] # nohup slon slony_example "dbname=pgbenchslave  host=localhost port=5432 user=slonyrep password=changeme" &
[2] 3985
[pg96slony:postgres:/tmp/slave] # nohup: ignoring input and appending output to ‘nohup.out’

[pg96slony:postgres:/tmp/slave] #  PGPASSWORD=changeme psql -U slonyrep -h localhost -p 5432 -d pgbenchslave -c "select count(*) from pgbench_branches;"
 count
-------
     1
(1 row)

[pg96slony:postgres:/tmp/slave] # ps -ef|grep slon
postgres  3968  3895  0 17:20 pts/0    00:00:00 slon slony_example dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme
postgres  3969  3968  0 17:20 pts/0    00:00:00 slon slony_example dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme
postgres  3973  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47480) idle
postgres  3979  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47482) idle
postgres  3980  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47484) idle
postgres  3981  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47486) idle
postgres  3982  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47488) idle
postgres  3983  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47490) idle
postgres  3985  3895  0 17:20 pts/0    00:00:00 slon slony_example dbname=pgbenchslave  host=localhost port=5432 user=slonyrep password=changeme
postgres  3986  3985  0 17:20 pts/0    00:00:00 slon slony_example dbname=pgbenchslave  host=localhost port=5432 user=slonyrep password=changeme
postgres  3990  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47494) idle
postgres  3996  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47496) idle
postgres  3997  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47498) idle
postgres  3998  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47500) idle
postgres  3999  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47502) idle
postgres  4000  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47504) idle
postgres  4002  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbench ::1(47508) idle
postgres  4003  3801  0 17:20 ?        00:00:00 postgres: slonyrep pgbenchslave ::1(47510) idle
postgres  4021  3895  0 17:21 pts/0    00:00:00 grep --color=auto slon
[pg96slony:postgres:/tmp/slave] # psql -U slonyrep -h localhost -p 5432 -d pgbenchslave -c "select count(*) from pgbench_branches;"
 count
-------
     1
(1 row)
```


## Useful documentation for slony (reference)

* https://www.slony.info/documentation/2.1/tutorial.html
* https://www.slony.info/documentation/stmtsetaddtable.html
* https://sites.google.com/site/pgsqldoc/Home/slony
* https://hub.packtpub.com/replication-solutions-postgresql/
* https://severalnines.com/blog/experts-guide-slony-replication-postgresql
* https://serverfault.com/questions/198002/postgresql-what-does-grant-all-privileges-on-database-d
* https://public.dalibo.com/exports/conferences/_archives/_2011/201110_slony/pgconfeu_slony.pdf 




## Earlier issues - setup seems almost complete although still hitting connectivity issues between master and slave 
To install slony we first need to install perl

```
  yum install -y perl
  yum install -y slony1-96
```

Initial DB setup ... 

```
  su -c "/usr/pgsql-12/bin/pgbench -i -s 1" -s /bin/sh vagrant
  su -c "pg_dump -s -p 5432 -h localhost pgbench | psql -h localhost -p 5432 pgbenchslave" -s /bin/sh vagrant
```


I'm struggling to get slony up and running, but making notes of all the challenges/steps I'm working through, this is a learning exercise...

* I've added md5 .pgpass entries as per https://www.slony.info/documentation/security.html and https://gazelle.ihe.net/content/adding-slave
* I also updated pg_hba.conf entries
* However the initiallisation following commanads only partially work
```
First  Session:
[pg96slony:vagrant:~] # pg
Last login: Thu Jan 21 21:02:58 UTC 2021
[pg96slony:postgres:~] # /usr/pgsql-9.6/bin/slonik /vagrant/init_master.slonik
[pg96slony:postgres:~] # /usr/pgsql-9.6/bin/slonik /vagrant/init_slave.slonik
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1

Second Session
[pg96slony:postgres:~] #  nohup slon slony_example "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" &
[1] 4100
[pg96slony:postgres:~] # nohup: ignoring input and appending output to ‘nohup.out’

[pg96slony:postgres:~] #
[pg96slony:postgres:~] # tail -f nohup.out
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbenchslave host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:18 UTC CONFIG cleanupThread: bias = 60
2021-01-21 21:13:18 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:18 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:20 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:20 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:20 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:20 UTC CONFIG remoteWorkerThread_2: update provider configuration
^C
[pg96slony:postgres:~] # tail -1000f nohup.out
2021-01-21 21:13:18 UTC CONFIG main: slon version 2.2.10 starting up
2021-01-21 21:13:18 UTC INFO   slon: watchdog process started
2021-01-21 21:13:18 UTC CONFIG slon: watchdog ready - pid = 4100
2021-01-21 21:13:18 UTC CONFIG slon: worker process created - pid = 4101
2021-01-21 21:13:18 UTC CONFIG main: Integer option vac_frequency = 3
2021-01-21 21:13:18 UTC CONFIG main: Integer option log_level = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option sync_interval = 2000
2021-01-21 21:13:18 UTC CONFIG main: Integer option sync_interval_timeout = 10000
2021-01-21 21:13:18 UTC CONFIG main: Integer option sync_group_maxsize = 20
2021-01-21 21:13:18 UTC CONFIG main: Integer option syslog = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option quit_sync_provider = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option remote_listen_timeout = 300
2021-01-21 21:13:18 UTC CONFIG main: Integer option monitor_interval = 500
2021-01-21 21:13:18 UTC CONFIG main: Integer option explain_interval = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option tcp_keepalive_idle = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option tcp_keepalive_interval = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option tcp_keepalive_count = 0
2021-01-21 21:13:18 UTC CONFIG main: Integer option apply_cache_size = 100
2021-01-21 21:13:18 UTC CONFIG main: Boolean option log_pid = 0
2021-01-21 21:13:18 UTC CONFIG main: Boolean option log_timestamp = 1
2021-01-21 21:13:18 UTC CONFIG main: Boolean option tcp_keepalive = 1
2021-01-21 21:13:18 UTC CONFIG main: Boolean option monitor_threads = 1
2021-01-21 21:13:18 UTC CONFIG main: Boolean option enable_version_check = 1
2021-01-21 21:13:18 UTC CONFIG main: Boolean option remote_listen_serializable_transactions = 1
2021-01-21 21:13:18 UTC CONFIG main: Real option real_placeholder = 0.000000
2021-01-21 21:13:18 UTC CONFIG main: String option cluster_name = slony_example
2021-01-21 21:13:18 UTC CONFIG main: String option conn_info = dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme
2021-01-21 21:13:18 UTC CONFIG main: String option pid_file = [NULL]
2021-01-21 21:13:18 UTC CONFIG main: String option log_timestamp_format = %Y-%m-%d %H:%M:%S %Z
2021-01-21 21:13:18 UTC CONFIG main: String option archive_dir = [NULL]
2021-01-21 21:13:18 UTC CONFIG main: String option sql_on_connection = [NULL]
2021-01-21 21:13:18 UTC CONFIG main: String option lag_interval = [NULL]
2021-01-21 21:13:18 UTC CONFIG main: String option command_on_logarchive = [NULL]
2021-01-21 21:13:18 UTC CONFIG main: String option syslog_facility = LOCAL0
2021-01-21 21:13:18 UTC CONFIG main: String option syslog_ident = slon
2021-01-21 21:13:18 UTC CONFIG main: String option cleanup_interval = 10 minutes
2021-01-21 21:13:18 UTC CONFIG main: local node id = 1
2021-01-21 21:13:18 UTC INFO   main: main process started
2021-01-21 21:13:18 UTC CONFIG main: launching sched_start_mainloop
2021-01-21 21:13:18 UTC CONFIG main: loading current cluster configuration
2021-01-21 21:13:18 UTC CONFIG storeNode: no_id=2 no_comment='Slave node'
2021-01-21 21:13:18 UTC CONFIG storePath: pa_server=2 pa_client=1 pa_conninfo="dbname=pgbenchslave host=localhost port=5432 user=slonyrep password=changeme" pa_connretry=10
2021-01-21 21:13:18 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:18 UTC CONFIG storeSet: set_id=1 set_origin=1 set_comment='All pgbench tables'
2021-01-21 21:13:18 UTC CONFIG main: last local event sequence = 5000000013
2021-01-21 21:13:18 UTC CONFIG main: configuration complete - starting threads
2021-01-21 21:13:18 UTC INFO   localListenThread: thread starts
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG enableNode: no_id=2
2021-01-21 21:13:18 UTC INFO   main: running scheduler mainloop
2021-01-21 21:13:18 UTC INFO   remoteListenThread_2: thread starts
2021-01-21 21:13:18 UTC CONFIG cleanupThread: thread starts
2021-01-21 21:13:18 UTC INFO   syncThread: thread starts
2021-01-21 21:13:18 UTC INFO   monitorThread: thread starts
2021-01-21 21:13:18 UTC INFO   remoteWorkerThread_2: thread starts
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbenchslave host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG version for "dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme" is 90620
2021-01-21 21:13:18 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:18 UTC CONFIG cleanupThread: bias = 60
2021-01-21 21:13:18 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:18 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:20 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:20 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:13:20 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:13:20 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:15:40 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 21:15:40 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 21:19:26 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
```
* Partially work in that they setup the _slony_example schema and added triggers

```
[pg96slony:postgres:~] # psql -d pgbench
psql (9.6.20)
pgbench=# \d+ pgbench_accounts
                       Table "public.pgbench_accounts"
  Column  |     Type      | Modifiers | Storage  | Stats target | Description
----------+---------------+-----------+----------+--------------+-------------
 aid      | integer       | not null  | plain    |              |
 bid      | integer       |           | plain    |              |
 abalance | integer       |           | plain    |              |
 filler   | character(84) |           | extended |              |
Indexes:
    "pgbench_accounts_pkey" PRIMARY KEY, btree (aid)
Triggers:
    _slony_example_logtrigger AFTER INSERT OR DELETE OR UPDATE ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE _slony_example.logtrigger('_slony_example', '1', 'k')
    _slony_example_truncatetrigger BEFORE TRUNCATE ON pgbench_accounts FOR EACH STATEMENT EXECUTE PROCEDURE _slony_example.log_truncate('1')
Disabled user triggers:
    _slony_example_denyaccess BEFORE INSERT OR DELETE OR UPDATE ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE _slony_example.denyaccess('_slony_example')
    _slony_example_truncatedeny BEFORE TRUNCATE ON pgbench_accounts FOR EACH STATEMENT EXECUTE PROCEDURE _slony_example.deny_truncate()
Options: fillfactor=100


[pg96slony:postgres:~] # psql -U slonyrep -h localhost -p 5432 -d pgbench
psql (9.6.20)
Type "help" for help.

pgbench=# \dn
      List of schemas
      Name      |  Owner
----------------+----------
 _slony_example | slonyrep
 public         | postgres
(2 rows)

pgbench=# SET search_path TO _slony_example, public;
SET
pgbench=# \x
Expanded display is on.
pgbench=# select * from sl_table;
-[ RECORD 1 ]----------------------
tab_id      | 1
tab_reloid  | 16393
tab_relname | pgbench_accounts
tab_nspname | public
tab_set     | 1
tab_idxname | pgbench_accounts_pkey
tab_altered | f
tab_comment | accounts table
-[ RECORD 2 ]----------------------
tab_id      | 2
tab_reloid  | 16396
tab_relname | pgbench_branches
tab_nspname | public
tab_set     | 1
tab_idxname | pgbench_branches_pkey
tab_altered | f
tab_comment | branches table
-[ RECORD 3 ]----------------------
tab_id      | 3
tab_reloid  | 16390
tab_relname | pgbench_tellers
tab_nspname | public
tab_set     | 1
tab_idxname | pgbench_tellers_pkey
tab_altered | f
tab_comment | tellers table
-[ RECORD 4 ]----------------------
tab_id      | 4
tab_reloid  | 16387
tab_relname | pgbench_history
tab_nspname | public
tab_set     | 1
tab_idxname | pgbench_history_pkey
tab_altered | f
tab_comment | history table
```

However the actual replication seems to be hanging 

```
[pg96slony:postgres:~] # PGPASSWORD=changeme psql -U slonyrep -h localhost -p 5432 -d pgbenchslave -c "select count(*) from pgbench_branches;"
 count
-------
     0
(1 row)

[pg96slony:postgres:~] # PGPASSWORD=changeme psql -U slonyrep -h localhost -p 5432 -d pgbench -c "select count(*) from pgbench_branches;"
 count
-------
     1
(1 row)
```


I suspect connectivity issues

```
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 slonyrep  | Superuser                                                  | {}
 vagrant   |                                                            | {}
```



NB I also trying to work through this example (https://hub.packtpub.com/replication-solutions-postgresql/#more) and using the postgres user


```
[pg96slony:postgres:~] # createdb test1
[pg96slony:postgres:~] # createdb test2
[pg96slony:postgres:~] # psql -d test1
psql (9.6.20)
Type "help" for help.

test1=# create table t_test (id numeric primary key, name
test1(#   varchar);
CREATE TABLE
test1=# insert into t_test values(1,'A'),(2,'B'), (3,'C');
INSERT 0 3
test1=#
test1=# \q
[pg96slony:postgres:~] # psql
psql (9.6.20)
Type "help" for help.
postgres=# alter user postgres with password 'changeme';
ALTER ROLE
postgres=# \q
[pg96slony:postgres:~] # vi ~/.pgpass
[pg96slony:postgres:~] # pg_dump -s -p 5432 -h localhost test1 | psql -h localhost -p 5432 test2
SET
..
CREATE EXTENSION
COMMENT
SET
SET
CREATE TABLE
ALTER TABLE
ALTER TABLE
[pg96slony:postgres:~] # psql -d  test2
psql (9.6.20)
Type "help" for help.

test2=# select * from t_test;
 id | name
----+------
(0 rows)

test2=# \q


[pg96slony:postgres:~] # head -20 init_*
==> init_master2.slonik <==
#! /bin/slonik
  cluster name = mycluster;
  node 1 admin conninfo = 'dbname=test1 host=localhost
port=5432 user=postgres password=changeme';
  node 2 admin conninfo = 'dbname=test2 host=localhost
port=5432 user=postgres password=changeme';
  init cluster ( id=1);
  create set (id=1, origin=1);
  set add table(set id=1, origin=1, id=1, fully qualified
name = 'public.t_test');
  store node (id=2, event node = 1);
  store path (server=1, client=2, conninfo='dbname=test1
host=localhost port=5432 user=postgres password=changeme');
  store path (server=2, client=1, conninfo='dbname=test2
host=localhost port=5432 user=postgres password=changeme');
  store listen (origin=1, provider = 1, receiver = 2);
  store listen (origin=2, provider = 2, receiver = 1);

==> init_slave2.slonik <==
#! /bin/slonik
  cluster name = mycluster;
  node 1 admin conninfo = 'dbname=test1 host=localhost
port=5432 user=postgres password=changeme';
  node 2 admin conninfo = 'dbname=test2 host=localhost
port=5432 user=postgres password=changeme';
subscribe set ( id = 1, provider = 1, receiver = 2,
  forward = no);
```  

but similar results i.e. the triggers and _mycluster (for slony metadata) are added but no data is replicated

```

[pg96slony:postgres:~] # slonik init_master2.slonik
init_master2.slonik:16: waiting for event (1,5000000007) to be confirmed on node 2
init_master2.slonik:16: waiting for event (1,5000000007) to be confirmed on node 2
init_master2.slonik:16: waiting for event (1,5000000007) to be confirmed on node 2
init_master2.slonik:16: waiting for event (1,5000000007) to be confirmed on node 2

[pg96slony:postgres:~] # slonik init_slave2.slonik
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1
waiting for events  (2,5000000001) only at (2,0) to be confirmed on node 1


[pg96slony:postgres:~] # nohup slon mycluster "dbname=test1 host=localhost port=5432
>   user=postgres password=changeme" &
[1] 8057
[pg96slony:postgres:~] # nohup: ignoring input and appending output to ‘nohup.out’

[pg96slony:postgres:~] # tail -1000f nohup.out
2021-01-21 23:37:05 UTC CONFIG main: slon version 2.2.10 starting up
2021-01-21 23:37:05 UTC INFO   slon: watchdog process started
2021-01-21 23:37:05 UTC CONFIG slon: watchdog ready - pid = 8057
2021-01-21 23:37:05 UTC CONFIG slon: worker process created - pid = 8058
2021-01-21 23:37:05 UTC CONFIG main: Integer option vac_frequency = 3
2021-01-21 23:37:05 UTC CONFIG main: Integer option log_level = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option sync_interval = 2000
2021-01-21 23:37:05 UTC CONFIG main: Integer option sync_interval_timeout = 10000
2021-01-21 23:37:05 UTC CONFIG main: Integer option sync_group_maxsize = 20
2021-01-21 23:37:05 UTC CONFIG main: Integer option syslog = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option quit_sync_provider = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option remote_listen_timeout = 300
2021-01-21 23:37:05 UTC CONFIG main: Integer option monitor_interval = 500
2021-01-21 23:37:05 UTC CONFIG main: Integer option explain_interval = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option tcp_keepalive_idle = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option tcp_keepalive_interval = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option tcp_keepalive_count = 0
2021-01-21 23:37:05 UTC CONFIG main: Integer option apply_cache_size = 100
2021-01-21 23:37:05 UTC CONFIG main: Boolean option log_pid = 0
2021-01-21 23:37:05 UTC CONFIG main: Boolean option log_timestamp = 1
2021-01-21 23:37:05 UTC CONFIG main: Boolean option tcp_keepalive = 1
2021-01-21 23:37:05 UTC CONFIG main: Boolean option monitor_threads = 1
2021-01-21 23:37:05 UTC CONFIG main: Boolean option enable_version_check = 1
2021-01-21 23:37:05 UTC CONFIG main: Boolean option remote_listen_serializable_transactions = 1
2021-01-21 23:37:05 UTC CONFIG main: Real option real_placeholder = 0.000000
2021-01-21 23:37:05 UTC CONFIG main: String option cluster_name = mycluster
2021-01-21 23:37:05 UTC CONFIG main: String option conn_info = dbname=test1 host=localhost port=5432
  user=postgres password=changeme
2021-01-21 23:37:05 UTC CONFIG main: String option pid_file = [NULL]
2021-01-21 23:37:05 UTC CONFIG main: String option log_timestamp_format = %Y-%m-%d %H:%M:%S %Z
2021-01-21 23:37:05 UTC CONFIG main: String option archive_dir = [NULL]
2021-01-21 23:37:05 UTC CONFIG main: String option sql_on_connection = [NULL]
2021-01-21 23:37:05 UTC CONFIG main: String option lag_interval = [NULL]
2021-01-21 23:37:05 UTC CONFIG main: String option command_on_logarchive = [NULL]
2021-01-21 23:37:05 UTC CONFIG main: String option syslog_facility = LOCAL0
2021-01-21 23:37:05 UTC CONFIG main: String option syslog_ident = slon
2021-01-21 23:37:05 UTC CONFIG main: String option cleanup_interval = 10 minutes
2021-01-21 23:37:05 UTC CONFIG main: local node id = 1
2021-01-21 23:37:05 UTC INFO   main: main process started
2021-01-21 23:37:05 UTC CONFIG main: launching sched_start_mainloop
2021-01-21 23:37:05 UTC CONFIG main: loading current cluster configuration
2021-01-21 23:37:05 UTC CONFIG storeNode: no_id=2 no_comment=''
2021-01-21 23:37:05 UTC CONFIG storePath: pa_server=2 pa_client=1 pa_conninfo="dbname=test2
host=localhost port=5432 user=postgres password=changeme" pa_connretry=10
2021-01-21 23:37:05 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 23:37:05 UTC CONFIG storeSet: set_id=1 set_origin=1 set_comment='A replication set so boring no one thought to give it a name'
2021-01-21 23:37:05 UTC CONFIG main: last local event sequence = 5000000007
2021-01-21 23:37:05 UTC CONFIG main: configuration complete - starting threads
2021-01-21 23:37:05 UTC INFO   localListenThread: thread starts
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test1 host=localhost port=5432
  user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG enableNode: no_id=2
2021-01-21 23:37:05 UTC INFO   main: running scheduler mainloop
2021-01-21 23:37:05 UTC INFO   remoteListenThread_2: thread starts
2021-01-21 23:37:05 UTC CONFIG cleanupThread: thread starts
2021-01-21 23:37:05 UTC INFO   syncThread: thread starts
2021-01-21 23:37:05 UTC INFO   monitorThread: thread starts
2021-01-21 23:37:05 UTC INFO   remoteWorkerThread_2: thread starts
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test1 host=localhost port=5432
  user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test1 host=localhost port=5432
  user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test2
host=localhost port=5432 user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test1 host=localhost port=5432
  user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG version for "dbname=test1 host=localhost port=5432
  user=postgres password=changeme" is 90620
2021-01-21 23:37:05 UTC CONFIG cleanupThread: bias = 60
2021-01-21 23:37:05 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 23:37:05 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 23:37:05 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 23:37:07 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 23:37:07 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 23:37:07 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 23:37:07 UTC CONFIG remoteWorkerThread_2: update provider configuration
2021-01-21 23:37:27 UTC CONFIG storeListen: li_origin=2 li_receiver=1 li_provider=2
2021-01-21 23:37:27 UTC CONFIG remoteWorkerThread_2: update provider configuration
NOTICE:  Slony-I: Logswitch to sl_log_2 initiated
2021-01-21 23:47:06 UTC INFO   cleanupThread:    0.024 seconds for cleanupEvent()
NOTICE:  Slony-I: log switch to sl_log_2 still in progress - sl_log_1 not truncated
2021-01-21 23:57:06 UTC INFO   cleanupThread:    0.004 seconds for cleanupEvent()
NOTICE:  Slony-I: log switch to sl_log_2 still in progress - sl_log_1 not truncated
2021-01-22 00:07:06 UTC INFO   cleanupThread:    0.009 seconds for cleanupEvent()
2021-01-22 00:07:06 UTC INFO   cleanupThread:    0.033 seconds for vacuuming
NOTICE:  Slony-I: log switch to sl_log_2 still in progress - sl_log_1 not truncated
2021-01-22 00:17:07 UTC INFO   cleanupThread:    0.004 seconds for cleanupEvent()
``` 


### Setting up slonyrep user with md5 

I'm not sure if this is the really the right approach, being a (slony newbie) but here is what I setup

```
~/projects/vagrant-pg96-slony $ cat setup_slonyrep_dbuser.sh
# to be run as postgres
createuser -S slonyrep
psql -c "create user slonyrep with password 'changeme'";
psql -d pgbench -c "GRANT ALL PRIVILEGES ON DATABASE pgbench TO slonyrep;";
psql -d pgbench -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO slonyrep;"
psql -d pgbenchslave -c "GRANT ALL PRIVILEGES ON DATABASE pgbenchslave TO slonyrep;";
psql -d pgbenchslave -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO slonyrep;"
```


and finally checking that I can 
```
[pg96slony:postgres:~] # PGPASSWORD=changeme psql -U slonyrep -d pgbenchslave -c "select count(*) from pgbench_branches;"
 count
-------
     0

```

### Debuging - Ident authentication failed

#### problem - Ident authentication failed for user "slonyrep
This was my rough startin point 
```
[pg96slony:vagrant:/vagrant] # cat init_master.slonik
#! /usr/pgsql-9.6/bin/slonik
  cluster name = mycluster;
  node 1 admin conninfo = 'dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme';
  node 2 admin conninfo = 'dbname=pgbenchslave host=localhost port=5432 user=slonyrep password=changeme'';
  init cluster ( id=1);
  create set (id=1, origin=1);
  set add table(set id=1, origin=1, id=1, fully qualified
name = 'public.t_test');
  store node (id=2, event node = 1);
  store path (server=1, client=2, conninfo='dbname=pgbench  host=localhost port=5432 user=slonyrep password=changeme');
  store path (server=2, client=1, conninfo='dbname=pgbenchslave host=localhost port=5432 user=slonyrep password=changeme');
  store listen (origin=1, provider = 1, receiver = 2);
  store listen (origin=2, provider = 2, receiver = 1);
```

and while this works

```
[pg96slony:vagrant:/vagrant] # PGPASSWORD=changeme psql -d pgbench  -p 5432 -U slonyrep
psql (9.6.20)
Type "help" for help.

pgbench=> \q
```
this doesn't

```
[pg96slony:vagrant:/vagrant] # PGPASSWORD=changeme psql -d pgbench -h 127.0.0.1  -p 5432 -U slonyrep
psql: FATAL:  Ident authentication failed for user "slonyrep"
```

I needed to update my pg_hba.conf

```
host    pgbench         slonyrep        127.0.0.1/32            md5
host    pgbench         slonyrep        localhost               md5
host    pgbenchslave    slonyrep        127.0.0.1/32            md5
host    pgbenchslave    slonyrep        localhost               md5
```


### Debug permission denied

#### problem - permission denied to set parameter "session_replication_role"

```
[pg96slony:postgres:/vagrant] # /usr/pgsql-9.6/bin/slonik init_master.slonik
init_master.slonik:5: PGRES_FATAL_ERROR SET datestyle TO 'ISO'; SET session_replication_role TO local;  - ERROR:  permission denied to set parameter "session_replication_role"
Unable to set session configuration parameters
init_master.slonik:5: PGRES_FATAL_ERROR SET datestyle TO 'ISO'; SET session_replication_role TO local;  - ERROR:  permission denied to set parameter "session_replication_role"
Unable to set session configuration parameters
init_master.slonik:5: PGRES_FATAL_ERROR select 1 from "pg_catalog".pg_namespace N 	where N.nspname = '_mycluster'; - ERROR:  current transaction is aborted, commands ignored until end of transaction block
init_master.slonik:5: Error: cannot determine  if namespace "_mycluster" exists in node 1
[pg96slony:postgres:/vagrant] #
```

#### solution add superuser role to replication user

```
[pg96slony:postgres:/vagrant] # psql -c "alter user slonyrep superuser"
ALTER ROLE
```


### Debug duplicate keys

#### problem - duplicate key value violates unique constraint sl_set-pkey

```
[pg96slony:postgres:~] # /usr/pgsql-9.6/bin/slonik /vagrant/init_master.slonik
/vagrant/init_master.slonik:7: PGRES_FATAL_ERROR lock table "_mycluster".sl_event_lock, "_mycluster".sl_config_lock;select "_mycluster".storeSet(1, 'All pgbench tables');  - ERROR:  duplicate key value violates unique constraint "sl_set-pkey"
DETAIL:  Key (set_id)=(1) already exists.
CONTEXT:  SQL statement "insert into "_mycluster".sl_set
			(set_id, set_origin, set_comment) values
			(p_set_id, v_local_node_id, p_set_comment)"
```

#### solution rebuild VM

The problem here was around try to initialize the master node multiple nodes:
* it is hard to unpick the slony internal schema
* in the real world I guess you should be careful, maybe you can backup slony schema before making changes
* in my case I rebuilt the VM (vagrant destroy;vagrant up ...)










### Diggging around in the _slony_example schema


```
[pg96slony:postgres:~] # psql -U slonyrep -h localhost -p 5432 -d pgbenchslave
psql (9.6.20)
Type "help" for help.

pgbenchslave=# select count(*) from pgbench_accounts;
 count
-------
     0
(1 row)

pgbenchslave=# \dn
      List of schemas
      Name      |  Owner
----------------+----------
 _slony_example | slonyrep
 public         | postgres
(2 rows)

pgbenchslave=# SET search_path TO _slony_example, public;
SET
pgbenchslave=# select * from sl_table;
 tab_id | tab_reloid | tab_relname | tab_nspname | tab_set | tab_idxname | tab_altered | tab_comment
--------+------------+-------------+-------------+---------+-------------+-------------+-------------
(0 rows)
```

Although I was seeing data is the master node




### Legacy step


The tutorial documentation (https://www.slony.info/documentation/2.1/tutorial.html) is a bit vauge, 

```
Because Slony-I depends on the databases having the pl/pgSQL procedural language installed, we better install it now. 
It is possible that you have installed pl/pgSQL into the template1 database in which case you can skip this step because it's already installed into the $MASTERDBNAME.
createlang -h $MASTERHOST plpgsql $MASTERDBNAME
```

but this step appears to legacy for my setup  

```
[pg96slony:postgres:~] # createlang plpgsql pgbench
createlang: language "plpgsql" is already installed in database "pgbench"
[pg96slony:postgres:~] # createlang plpgsql pgbenchslave
createlang: language "plpgsql" is already installed in database "pgbenchslave"
```




