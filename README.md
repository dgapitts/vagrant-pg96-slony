## Summary


Training environment for learning how to setup slony replication

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

To be completed ...

```
~/projects/vagrant-pg96-slony $ vagrant ssh
psqlLast login: Thu Jan 21 10:54:54 2021
psql [pg96slony:vagrant:~] # psql -d pgbench
psql (9.6.20)
Type "help" for help.

pgbench=> \l
                                   List of databases
     Name     |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
--------------+----------+----------+-------------+-------------+-----------------------
 pgbench      | vagrant  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pgbenchslave | vagrant  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
              |          |          |             |             | postgres=CTc/postgres
 template1    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
              |          |          |             |             | postgres=CTc/postgres
(5 rows)

pgbench=> \d
No relations found.
pgbench-> \q
[pg96slony:vagrant:~]
```

Ref:
* https://www.slony.info/documentation/2.1/tutorial.html
* https://hub.packtpub.com/replication-solutions-postgresql/
* https://severalnines.com/blog/experts-guide-slony-replication-postgresql

