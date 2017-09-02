# Crosscompile Setup for the Raspberry Pi 3

Simple setup to crosscompile the rpi3 kernel on a machine not suitable for linux development. Uses Vagrant to setup a virtual machine for compilation. Provides a shellscript to download the tools needed to get started.

## Get started

If you already have an environment suitable for linux development (case-sensitive filesystem and similar), just run look at `provisioning/crosscompiling.sh`. Either run it directly or take inspiration.

Otherwise you need to complete a few steps.

- Install [VirtualBox][virtualbox] or similar virtualization
- Install [Vagrant][vagrant] or create a suitable VM manually

[virtualbox]: https://www.virtualbox.org/ "Oracle VM VirtualBox"
[vagrant]: https://www.vagrantup.com/ "Vagrant by HashiCorp"

If you went with Vagrant the following commands executed in the root of this directory will give you a suitable VM.

```$ vagrant up && vagrant ssh```

This should create the VM, copy the shell script to the newly created VM, and use ssh to connect to it.

(Take a look at [Getting Started guide][vagrant-guide] if you are unfamiliar with Vagrant.)

[vagrant-guide]: https://www.vagrantup.com/intro/getting-started/index.html "Vagrant Getting Started"

## The `crosscompiling.sh` script

Simply execute it and keep your fingers crossed. It should download the crosscompilation tools needed, the source code for the linux kernel, create a symlink to the directory with the tools as `bin`, and finally try to compile the kernel. The kernel compilation alone takes aroung 30 minutes on my old laptop running a VM with 2 cores.

You might need to change you `PATH`-variable to include the tools folder.
