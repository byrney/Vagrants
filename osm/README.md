
Open Street Map Tile Server
===========================

Openstreetmap plus a PostGIS database with the data loaded for Devon (UK).

The data is loaded in planet_osm format using osm2pgsql and in routable format
using osm2pgrouting.

After the guest is provisioned, go to

    http://localhost:4000/osm/slippymap.html

to see the tiles. On Devon is imported so navgiate there on the map.


Or log into the box

    vagrant ssh

and the database

    psql -p 5452 -d gis

to see the schema

References:
==========

https://wiki.debian.org/OSM/tileserver/jessie#Serving_Tiles

https://launchpad.net/~kakrueger/+archive/ubuntu/openstreetmap

https://switch2osm.org/serving-tiles/manually-building-a-tile-server-12-04/

http://download.geofabrik.de/europe/great-britain/england/devon.html

https://github.com/pgRouting/osm2pgrouting

