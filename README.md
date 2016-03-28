
Vagrant Boxes
=============

This is a collection of vagrant setups that I use. For debian 8 or windows on 
some combination of VirtualBox, AWS and Azure.

Previously these were in seperate repos with a lot of duplication in the
provisioning setup.  Now I have them in one repo with all the provisiong
scripts shared.

It's still some way from my ideal as there is a mixture of and hand-written
scripts.  Partly it's because I have not migrated everything
over. Where manual scripts are used it's apt-get for debian and
powershell/chocolatey for windows.

In all cases the vagrant user is set up with the usual password. Networking is
largely NAT but open ports are always mapped to the host loopback address so
they are not exposed.

Host Setup
----------

For provisioning the host needs

* berkshelf  (by installing chefdk)
* vagrant-berkshelf plugin   `vagrant plugin install vagrant-berkshelf`

AWS boxes need

* awscli
* AWS environment variables

Azure boxes need

* azure-cli  (or equivalent)
* Download azure account settings
* vagrant-azure plugin

Boxes
----

```
2uda         -- postgres + orange from 2ndQuadrant on debian on virtualbox
aws          -- debian on aws
azure-win8   -- windows dev workstation on azure
cassandra    -- datastaxx cassandra on debian
debian-azure -- debian base on azure
jessie       -- debian server with a few tools on virtualbox
jessie2      -- debian workstation setup  (xorg etc) on virtualbox
modern       -- modern-IE windows workstation build on virtualbox
mssql        -- MS SQL on windows 8 on virtualbox
sybase       -- sysbase 16 on debian on virtualbox  (this is a WIP)
windows10    -- windows 10
windows8     -- windows 8 workstation setup with devtools on virtualbox
yosemite     -- OSX build with automated tools and users on virtualbox
oracle-xe    -- An oracle XE install on debian
postgres-xl  -- Two postgres XL nodes on a debian VM
docker       -- Vanilla docker setup on debian
```


The windows boxes typically have some work to create the base box.
Instructions in the readme. The debian and OSX boxes should download from
hashicorp.

AWS and Azure require setup and credentials before they will work. AWS setup
follows the usual approach for AWS commandline (setting environment
variables). Azure setup requires the azure-cli be installed and settings
downloaded plus a few extra steps described here:
http://www.sciencedirect.com/science/article/pii/S0195666316300459

The OSX box is one I use for testing my OSX bootstrap scripts so it mounts
some local folders and runs the scripts from there. It also needs the base box
to be hacked a bit to get it to provision more than once.

Change the provScript in
`$HOME/.vagrant.d/boxes/{boxname}/{version}/include/_Vagrantfile` to this


```
$provScript = <<__EOF__
diskutil list | grep -v disk0s3 || diskutil mergePartitions HFS+ Yosemite
disk0s2 disk0s3
__EOF__
```

so that the merge only gets called the first boot


