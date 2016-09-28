# CKAN-Chef

A Vagrant deployment of CKAN using Chef as provisioner.

Creates an Ubuntu 12.04 VM running Postgres 9.4, Solr, Jetty, CKAN (master) and Datastore.

## Installation

Install VirtualBox, Vagrant, Berkshelf and vagrant plugins:

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Install Berkshelf by installing the [ChefDK](https://downloads.chef.io/chef-dk/)
4. Install vagrant-berkshelf plugin with: `$ vagrant plugin install vagrant-berkshelf`
5. Install vagrant-hostmanager plugin with: `$ vagrant plugin install vagrant-hostmanager`

Clone this repository, then:

### For Development

`$ vagrant up`

Log in to the Vagrant VM:

`$ vagrant ssh`

Start the development server in the Vagrant VM:

```
$ cd /usr/lib/ckan/default/src/ckan
$ source ../../bin/activate
$ paster serve /etc/ckan/default/development.ini
```

View CKAN in your browser at `http://localhost:5000`.

If you're working on frontend development and want to watch for changes to less files, run the `less` file from the ckan source directory:

```
$ cd /usr/lib/ckan/default/src/ckan
$ source ../../bin/activate
$ node ./bin/less
```

### For Production

Add `recipe[ckan::ckan_production]` to your run_list to install the dependencies needed for a production instance of CKAN that uses Apache/Nginx.

To use with Vagrant, uncomment `include_recipe "ckan::ckan_production"` in the default recipe `ckan/recipes/default.rb`, then,

`$ vagrant up`

The production instance can be viewed with the host machine's browser at `http://default.ckanhosted.dev/`, by default.

## Vagrant synced folders

To make it easier to edit CKAN source and configuration files from the host machine, Vagrant synced_folders are defined as follows by default.

* `synced_folders/config`: maps to `/etc/ckan/default` on the guest VM.
* `synced_folders/src`: maps to `/usr/lib/ckan/default/src` on the guest VM.
* `synced_folders/file_storage`: maps to `/var/lib/ckan/default` on the guest VM.

These mappings are defined in the `Vagrantfile`.

## Vagrant commands

Some useful Vagrant commands:

`$ vagrant up` Create and configure the guest machine.

`$ vagrant ssh` Login to the guest machine.

`$ vagrant suspend` Suspend the current state of the guest machine.

`$ vagrant halt` Attempt a shutdown of the guest machine.

`$ vagrant provision` Re-provision the guest machine according to the Chef cookbook.

`$ vagrant reload` Restart the guest machine. Add the `--provision` flag to also re-provision.

`$ vagrant destroy` Stops the guest machine and removes all of its resources. This will destroy the CKAN database and any uncommitted changes to the source code in the guest machine.

See [Vagrant documentation](http://docs.vagrantup.com/v2/cli/index.html) for a full list of commands.

## Recipes

* `recipe[ckan::default]` collects together `ckan_base` and `ckan_datastore`.
* `recipe[ckan::ckan_base]` sets up everything needed for a CKAN instance ready for development.
* `recipe[ckan::ckan_datastore]` sets up the Datastore extension.
* `recipe[ckan::ckan_production]` sets up an Apache/Nginx server for serving CKAN in production.
* `recipe[ckan::ckan_tests]` sets up test database for ckan and ckanext tests.

## Attributes

CKAN configuration properties and installation locations can be tweaked in the attributes file: `/ckan/attributes/default.rb`.

Based on Victor Baptista's [chef-ckan](https://github.com/vitorbaptista/chef-ckan).


