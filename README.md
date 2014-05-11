# rogoto-puppet

Puppet Scripts for deploying Rogoto onto a Raspberry Pi.
To make sure that you have the necessary items setup, run
    $ sudo ./setup.sh
which will download all the necessary items. Once that has been done
run the command below.

It works by running the following in the command prompt::
    $ puppet apply manifests/default.pp

## Developing scripts

If you want to develop this against a virtual machine you can
always use Vagrant. It uses the vagrant file and then runs the
Puppet script.
