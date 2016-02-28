
A set of scripts to set up a windows8  (or 8.1) vagrant base box using
virtualbox provider.

Get the scripts onto the Host
----------------------------

1.  clone the repo

    git clone <remote repo url>

2.  Switch to the x64 branch  (should work for 32 bit windows but contains the
    newest version of the scripts

Create the base as a Guest
-------------------------

1.  Create a vanilla install of windows under VirtualBox
2.  Apply as many windows updates as possible  rebooting and repeating as
    necessary
3.  Install Virtualbox guest additions (menu item in VirtualBox)
4.  Copy the BaseSetup scripts onto the VM somehow (share a folder from the
    host is probably easiest)
5.  In an admin shell run Basesetup/vagrant_prepare.ps1 which will 
    * Create the vagrant user
    * Mark the network as private
    * Enable winrm
6.  Apply any other customizations you want to the box
7.  Wait for the windows updates to complete.
8.  Unmap any shared folders from the guest if you created any
9.  Run the BaseSetup/compact.ps1 script which will attempt to clean the hard
    disk as much as possible.
10. Reboot your VM and make sure it all comes up ok
11. Run the compact script one more time

Now you have your windows base image set up in VirtualBox. 

Create a Vagrant box on the Host
-------------------------------

1.  Shut down the VM
2.  Back on the host, Export/Package the box

    vagrant package --base name-of-VM --out win81.box

3.  Once the box is created import it  [1]

    vagrant box add --name win81 --provider virtualbox  win81.box

4.  Replace the username in config.cmd where it has Users/Robert

5.  Try it out: [2]

    vagrant up



[1] Once imported, if short on disk space, you can delete the .box file it is
    no longer needed

[2]  To help with fixing the scripts you can do the following:

    vagrant up --no-provision

which will bring the VM up but not run the provisioning scripts.

Then take a snapshot in Virtualbox to serve as a clean baseline. Then run the
provisioning

    vagrant provision


if it has problems you can restore the snapshot and provision again until it
works.




