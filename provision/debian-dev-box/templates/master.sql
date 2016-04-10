create extension if not exists pglogical;

select pglogical.drop_node('master', false);

SELECT pglogical.create_node(
    node_name := 'master',
    dsn       := 'host=localhost port=5432 dbname=vagrant'
);

\include_relative schema.sql

SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

