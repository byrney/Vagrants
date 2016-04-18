create extension if not exists pglogical;

select pglogical.drop_node('lead', false);

SELECT pglogical.create_node(
    node_name := 'lead',
    dsn       := 'host=localhost port=5442 dbname=vagrant'
);

\include_relative schema.sql

SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

