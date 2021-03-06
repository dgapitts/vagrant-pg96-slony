#! /bin/bash
if [ ! -f /home/vagrant/already-installed-flag ]
then
  echo "ADD EXTRA ALIAS VIA .bashrc"
  cat /vagrant/bashrc.append.txt >> /home/vagrant/.bash_profile
  cat /vagrant/bashrc.append.txt >> /root/.bashrc
  echo "alias pg='sudo su - postgres'" >> /home/vagrant/.bashrc
  echo "alias bench='sudo su - bench1'" >> /home/vagrant/.bashrc
  #echo "GENERAL YUM UPDATE"
  #yum -y update
  #echo "INSTALL GIT and bc"
  #yum -y install git
  #yum -y install bc  
  #echo "INSTALL TREE"
  #yum -y install tree
  #echo "INSTALL unzip curl wget"
  yum  -y install unzip curl wget

  # prevent vagrant user ssh warning "setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory"
  cat /vagrant/environment >> /etc/environment 
  
  # Install the repository RPM:
  yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  yum -y install postgresql96 postgresql96-server postgresql96-libs postgresql96-contrib postgresql96-devel
  yum install -y postgresql96-server
  
  
  yum install -y perl
  yum install -y slony1-96

   # Optionally initialize the database and enable automatic start:
   /usr/pgsql-9.6/bin/postgresql96-setup initdb
   systemctl enable postgresql-9.6
   systemctl start postgresql-9.6

  # setup vagrant postgres user and database
  su -c "createuser vagrant" -s /bin/sh postgres
  su -c "createdb -O vagrant pgbench"  -s /bin/sh postgres
  su -c "createdb -O vagrant pgbenchslave"  -s /bin/sh postgres
  su -c "/usr/pgsql-9.6/bin/pgbench -i -s 1 -d pgbench" -s /bin/sh vagrant
  su -c "bash /vagrant/add-pgbench_history-candidate-PK-for-slony.sh" -s /bin/sh vagrant
  su -c "pg_dump -s -d pgbench -U vagrant | psql -d pgbenchslave -U vagrant" -s /bin/sh vagrant
  #su -c "psql -d postgres -c $$alter user slonyrep with password 'changeme'$$"  -s /bin/sh postgres
  su -c "bash /vagrant/setup_slonyrep_dbuser.sh"  -s /bin/sh postgres
  su -c "createuser slonyrep -P changeme -g pgbench" -s /bin/sh postgres

  yum -y install python-psycopg2
  cat /vagrant/bashrc.append.txt >> /tmp/bashrc.append.txt
  su -c "cat /tmp/bashrc.append.txt >> ~/.bashrc" -s /bin/sh postgres
  su -c "cat /tmp/bashrc.append.txt >> ~/.bash_profile" -s /bin/sh postgres
  echo 'export PATH="$PATH:/usr/pgsql-9.6/bin"' >> /var/lib/pgsql/.bash_profile
  
  yum -y install sysstat
  systemctl start sysstat 
  systemctl enable sysstat
  sed -i 's#*/10#*/1#g' /etc/cron.d/sysstat
  #/vagrant/quick-start-setup-pg-ora-demo-scripts.sh
  
  # https://www.slony.info/documentation/security.html
  su -c "echo 'localhost:5432:pgbench:slonyrep:changeme' >> ~/.pgpass" -s /bin/sh postgres
  su -c "echo 'localhost:5432:pgbenchslave:slonyrep:changeme' >> ~/.pgpass" -s /bin/sh postgres
  su -c "echo 'localhost:5432:pgbench:postgres:changeme' >> ~/.pgpass" -s /bin/sh postgres
  su -c "echo 'localhost:5432:pgbenchslave:postgres:changeme' >> ~/.pgpass" -s /bin/sh postgres
  su -c "chmod 600 ~/.pgpass" -s /bin/sh postgres


  # initial cron
  crontab /vagrant/root_cronjob_monitoring_sysstat_plus_custom_pgmon.txt


  # default pg_hba.conf doesn't allow md5 i.e. password based authentication 
  cp /vagrant/pg_hba.conf /tmp/pg_hba.conf
  su -c "cp -p /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.`date '+%Y%m%d-%H%M'`.bak" -s /bin/sh postgres
  su -c "cat /tmp/pg_hba.conf > /var/lib/pgsql/9.6/data/pg_hba.conf" -s /bin/sh postgres
  # set listen_addresses='*' in postgresql.conf
  cp /vagrant/postgresql.conf /tmp/postgresql.conf
  su -c "cp -p /var/lib/pgsql/9.6/data/postgresql.conf /var/lib/pgsql/9.6/data/postgresql.conf.`date '+%Y%m%d-%H%M'`.bak" -s /bin/sh postgres
  su -c "cat /tmp/postgresql.conf > /var/lib/pgsql/9.6/data/postgresql.conf" -s /bin/sh postgres
  systemctl stop postgresql-9.6
  systemctl start postgresql-9.6
  systemctl status postgresql-9.6

  # and finally initialize slony master and slave, plus start the master and slave processes
  cp /vagrant/setup_slony_master_and_slave.sh /tmp/setup_slony_master_and_slave.sh
  su -c "bash /tmp/setup_slony_master_and_slave.sh" -s /bin/sh postgres

 

  
else
  echo "already installed flag set : /home/vagrant/already-installed-flag"
fi
