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

