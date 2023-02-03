## Minimal vm's automated creation

Description
-------
The code of this repository is to automate the creation of minimal virtual machine instances.
The propouse of this vm's is to be used as empty environments to test new stuff
or have separated labs with diferent technologies or configurations.

Requirements
-------
- Available disk space of 2GB in /var/lib
- [Fedora 30 Cloud Base image](https://alt.fedoraproject.org/cloud/)

Parameters
-------
|          Parameter        | Defaults |                   Comments                         |
|---------------------------|----------|----------------------------------------------------|
| ```vm_name```             |          | The name you want to give to the vm                |
| ```path_to_qcow2_image``` |          | Where is the base image to use                     |
| ```root_passwd```         | Optional. Default: ***redhat*** |  Specify a root password    |
| ```ssh_key```             |          | Where is the ssh key to inject into the minimal vm |
| ```img_path```            | Optional. Default: /var/lib/libvirt/images | Path to store the qcow2 images |


**root needed. Why?**
-------
To execute this script you need to have root permission because this script
generates the files in a specific path with only root access.

How to use
-------
Example:
```bash
./create-new-vm.sh <vm_name> <path_to_qcow2_image> <keys_path> <img_path> <root_passwd>
```

Clean up
------
If you used the default value of ```img_path``` all the images are stored there. If you want to delete the disk of a vm you should deleted from there. **Be careful to don't delete other image in use**.



How to increase disk size
-----

```bash
  188  cp Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2 Fedora-Cloud-Base-34-1-40.2.x86_64_original.qcow2
  189  virt-resize --expand /dev/vda1 Fedora-Cloud-Base-34-1-40.2.x86_64_original.qcow2 Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2
  190  export LIBGUESTFS_BACKEND=direct
  191  virt-resize --expand /dev/vda1 Fedora-Cloud-Base-34-1-40.2.x86_64_original.qcow2 Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2
  192  qemu-img info Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2 
  193  virt-filesystems –long -h –all -a Fedora-Cloud-Base-34-1-40.2.x86_64_original.qcow2
  194  qemu-img info Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2 
  195  virt-filesystems –long -h –all -a Fedora-Cloud-Base-34-1-40.2.x86_64.qcow2
```


KVM virsh commands
------

```bash
# List IP addresses from instances
sudo virsh net-dhcp-leases default

# List default network in the host
sudo virsh net-info default
```