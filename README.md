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

./create-new-vm.sh ubuntu-prometheus ../images/ubuntu/jammy-server.qcow2 keys/vm-key
./create-new-vm.sh ubuntu-prometheus ../images/ubuntu/ubuntu-22.04-serveramd64.qcow2 keys/vm-key
./create-new-vm.sh ubuntu-prometheus ../images/ubuntu/bionic-server.qcow2 keys/vm-key
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
### Option 1
# List IP addresses from instances
sudo virsh net-dhcp-leases default

# List default network in the host
sudo virsh net-info default

### Option 2
# list vms
sudo virsh list

sudo virsh domifaddr ubuntu-prometheus-vm
```


Download more images
------

- [OpenStack Get more images](https://docs.openstack.org/image-guide/obtain-images.html)
- [Convert img to qcow2 qemu](https://docs.openstack.org/image-guide/convert-images.html)

```bash
qemu-img convert -f img -O qcow2 bionic.img bionic.qcow2

sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  bionic-server-cloudimg-amd64.qcow2 \
  bionic-server.qcow2


wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

qemu-img create -F qcow2 -b focal-server-cloudimg-amd64.img -f qcow2 vm01.qcow2 10G

export MAC_ADDR=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

export INTERFACE=eth01

export IP_ADDR=192.168.122.101

cat >network-config <<EOF
ethernets:
    $INTERFACE:
        addresses: 
        - $IP_ADDR/24
        dhcp4: false
        gateway4: 192.168.122.1
        match:
            macaddress: $MAC_ADDR
        nameservers:
            addresses: 
            - 1.1.1.1
            - 8.8.8.8
        set-name: $INTERFACE
version: 2
EOF

cat >user-data <<EOF
#cloud-config
hostname: vm01
manage_etc_hosts: true
users:
  - name: vmadm
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/vmadm
    shell: /bin/bash
    lock_passwd: false
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    vmadm:vmadm
  expire: false
EOF

touch meta-data

cloud-localds -v --network-config=network-config vm01-seed.qcow2 user-data meta-data

virt-install --connect qemu:///system \
  --virt-type kvm \
  --name vm01 \
  --ram 1024 --vcpus=2 \
  --os-type linux --os-variant ubuntu20.04 \
  --disk path=vm01.qcow2,device=disk \
  --disk path=vm01-seed.qcow2,device=disk \
  --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
```

[ubuntu vm on kvm](https://yping88.medium.com/use-ubuntu-server-20-04-cloud-image-to-create-a-kvm-virtual-machine-with-fixed-network-properties-62ecae025f6c)

[qemu reference](https://blog.programster.org/create-ubuntu-22-kvm-guest-from-cloud-image)