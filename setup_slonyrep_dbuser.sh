# to be run as postgres
createuser slonyrep
psql -c "alter user slonyrep with password 'changeme'"
psql -c "alter user slonyrep superuser"
psql -d pgbench -c "GRANT ALL PRIVILEGES ON DATABASE pgbench TO slonyrep"
psql -d pgbench -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO slonyrep"
psql -d pgbenchslave -c "GRANT ALL PRIVILEGES ON DATABASE pgbenchslave TO slonyrep"
psql -d pgbenchslave -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO slonyrep"
