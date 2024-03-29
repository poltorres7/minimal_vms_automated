#!/usr/bin/env bash
# This bash script creates a new minimal virtual machine
#
# Author: Paul Torres @pol_torres7
#
# Instructions:
# Execute this script as root. To have the correct permisions to
# generate the files in the specific path
# Example:
# $./create-new-vm.sh <vm_name> <path_to_qcow2_image> <keys_path> <root_passwd> <memory> <cpu> <img_path>
#

set -euo pipefail

# vars
vm_name="$1"     # Name to virtual machine
source_img="$2"  # Path of the img to use
keys_path="$3"
root_passwd="${4:-redhat}" # Optional
memory="${5:-1024}"
cpu="${6:-1}"
img_path="${7:-/var/lib/libvirt/images}" # Optional

mydate=`date "+%d-%H%M"`
vm_name_ftm="${vm_name}-vm-${mydate}.qcow2"

main () {
  # Copying image
  echo "	Copying image"
  sudo cp "${source_img}" "${img_path}/${vm_name_ftm}"
  sudo ls -l "${img_path}/${vm_name_ftm}"

  conf_vm
  import_vm
} # End of function main  

conf_vm () {
  # Configure the VM
  echo "	Configuring image"
  sudo virt-customize -a "${img_path}/${vm_name_ftm}" \
	--hostname "${vm_name}.lodbrok.lab" --root "password:${root_passwd}" \
	--ssh-inject "root:file:${keys_path}" --uninstall cloud-init \
	--selinux-relabel
#  --install "vim" \
} # End of function conf_vm

import_vm () {
  # Import the VM
  echo "	Importing image"

  date_with_time=`date "+%y%m%d-%H%M%S"`

  sudo virt-install --name "${vm_name}-vm" --memory ${memory} \
	--vcpus ${cpu} --disk "${img_path}/${vm_name_ftm}" --disk size=20 \
       	--import --os-variant fedora29 --noautoconsole
}

main
