# Modern IE Vagrant Setup with Chef #

This machine is not meant to be used for anything it's simply
a way of taking the ms provided vagrant boxes for IE testing and create
a usable box that allows remote provisioning.

The images provided by MS expire after 90 days so this process will have to be
repeated.


1. Install Prerequisites
2. Get the Vagrant Box for IE Modern
3. Prepare the guest
4. Start up and provision with chef + vagrant

## Prerequisites ##

### Install Virtualbox ###


### Install vagrant on the host ###

Either download it from here

    https://www.vagrantup.com/downloads

or use you package manager of choice

### Install chef dev kit on the host ###

Download from opscode

    https://downloads.chef.io/chef-dk/

or, again, use you package manager

### Install the vagrant-berkshelf-plugin ##

Once vagrant is install this can be done with

    vagrant plugin install vagrant-berkshelf

on the commandline  (see   https://github.com/berkshelf/vagrant-berkshelf  for
more details )

## Get the Vagrant Box ##

Clone this repo

```bash
git clone https://github.com/byrney/Vagrants
```

change to the right directory and launch the box

```bash
    cd modern7
    vagrant up
```

This will download the image from aka.ms and could take a couple of hours
depending

The box will start in the VirtualBox GUI but vagrant will fail because the box
has not be set-up to allow remote access (see below for example of the error).

You should see this:

```
> vagrant up

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 5985 => 5985 (adapter 1)
    default: 3389 => 3389 (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: WinRM address: 127.0.0.1:5985
    default: WinRM username: vagrant
    default: WinRM transport: plaintext
An error occurred executing a remote WinRM command.

Shell: powershell
Command: hostname
if ($?) { exit 0 } else { if($LASTEXITCODE) { exit $LASTEXITCODE } else { exit 1 } }
Message: Protocol wrong type for socket
```

Go to the VM GUI and open a command window as admin (right click on the start
button and select from the menu). Then

```PowerShell
powershell
Set-ExecutionPolicy -executionpolicy remotesigned -force
net use z: \\vboxsvr\vagrant
. z:\vagrant_prepare.ps1
```

this should prep-the box for vagrant to be able to connect via winrm as user
`vagrant`.

## Configure your base box

If you're going to be using this for 90 days then you want to get as much of
the gui-only configuration into the base image. Things like

* Apply as many windows updates as possible
* Disable any unnecessary services
* Turn off windows firewall
* Turn off Windows Defender
* Show file extensions in Explorer
* Log in once as vagrant so the stock apps get set up
* Set your language
* ... and so on

Let it reboot so that the updates get installed, then check for updates again
(repeat until no more updates arrive)

You can save yourself 400MB if you remove some components and optimize the
drive in the image prior to export.


## Save the prepared image ##

1.  Shut down the VM

    vagrant halt

2.  Back on the host, Export/Package the box

    vagrant package --base modern8 --out modern8.box

3.  Once the box is created import it

    vagrant box add --name win7 --provider virtualbox  --force modern7.box

This will create a new box `win7` that contains all your customizations

You can delete the `modern7.box` file now.

## Start up with vagrant ##

You can now modify the Vagrantfile (or better, make a copy and modify that) to
use `win7` box and it should complete without errors now.

```bash
vagrant up
```

When the prepare script has worked you will see this:

```
> vagrant up

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 5985 => 5985 (adapter 1)
    default: 3389 => 3389 (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: WinRM address: 127.0.0.1:5985
    default: WinRM username: vagrant
    default: WinRM transport: plaintext
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: Guest Additions Version: 4.3.10
    default: VirtualBox Version: 5.0
==> default: Mounting shared folders...
    default: /vagrant => /Users/rob/Documents/Vagrant/modern

```

## Repeat

The `modern7` box registered with vagrant is the original ms image without
activation so issuing

    vagrant destroy -f && vagrant up

in the modern8 folder will get you back to the beginning of this sequence so
you can generate a new win81 after 90 days. This skips the download but, of
course, the manual steps to configure the image will have to be repeated.


