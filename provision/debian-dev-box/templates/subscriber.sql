
create extension if not exists pglogical;

select pglogical.drop_node('subscriber', false);

SELECT pglogical.create_node(
    node_name := 'subscriber',
    dsn := 'host=localhost port=5433 dbname=vagrant'
);

-- no schema!!
-- \include_relative schema.sql

select pglogical.create_subscription(
    subscription_name := 'subscription1',
    provider_dsn := 'host=localhost port=5432 dbname=vagrant'
);


