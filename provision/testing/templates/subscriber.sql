
create extension if not exists pglogical;

select pglogical.drop_node('follow', false);

SELECT pglogical.create_node(
    node_name := 'follow',
    dsn := 'host=localhost port=5443 dbname=vagrant'
);

-- no schema!!
-- \include_relative schema.sql

select pglogical.create_subscription(
    subscription_name := 'subscription1',
    provider_dsn := 'host=localhost port=5442 dbname=vagrant'
);


