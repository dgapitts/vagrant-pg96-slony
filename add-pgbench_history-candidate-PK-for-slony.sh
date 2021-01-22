# https://www.slony.info/documentation/2.1/tutorial.html
# One of the tables created by pgbench, pgbench_history, does not have a primary key. Slony-I requires that there is a suitable candidate primary key.  
# The following SQL requests will establish a proper primary key on this table:
psql -d pgbench -c "begin; alter table pgbench_history add column id serial; update pgbench_history set id = nextval('pgbench_history_id_seq'); alter table pgbench_history add primary key(id); commit;"
