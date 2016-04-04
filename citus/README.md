
Citus Setup
==========

This sets up 2 VMs each running 2 postgres-95 nodes with the citus
extension installed.

Boxes:

* primary = 192.168.50.10
* secondary = 192.160.50.11

Instances:

* master = primary:9700
* work01 = primary:9701
* work02 = secondary:9700
* work03 = secondary:9701

The databases are normal postgres-95 installs from apt.postgresql.org with the
citus extension installed on top.


Connect to the master with

    vagrant ssh primary -c 'psql -p 9700'



