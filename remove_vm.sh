#!/bin/bash
# Copyright (C) 2018, Siemens AG, Zoran Stojsavljevic
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

## Prepare all the relevant data for removing the vagrant machine
cd $HOME/.config/VirtualBox
VBOX_IMG_DIR=`cat VirtualBox.xml | grep defaultMachineFolder | grep -o -P '(?<=").*(?=" default)'`
echo $VBOX_IMG_DIR
cd -

if [ ! -d ".vagrant" ]; then
    echo "vagrant machine not created"
    exit 1
fi

vm_id=`cat .vagrant/machines/default/virtualbox/id`
echo $vm_id
vbox_name=`vboxmanage list vms | grep $vm_id | sed 's/_/ /' | cut -f1 -d" " | sed 's/"//'`
vagrant_name=`vagrant box list | grep $vbox_name | cut -f1 -d" "`
echo "vbox name is $vbox_name"
echo "vagrant name is $vagrant_name"

echo "what vagrant machines are in the system?"
vagrant box list

## Start removal of the $vagrant_name machine
vagrant box remove $vagrant_name

echo "which machines are left removal of $vagrant_name?"
vagrant box list

rm Vagrantfile
rm -rf .vagrant

## Start removal of the $vagrant_name VirtualBox machine
cd $VBOX_IMG_DIR
pwd
echo "all the existing VM machines in $VBOX_IMG_DIR:"
ls -al
echo "present VMs in the system:"
vboxmanage list vms

echo "$vm_id vm machine to be shut down"
VBoxManage controlvm "${vm_id}" poweroff
sleep 2
echo "$vm_id vm machine to be removed"
vboxmanage unregistervm "${vm_id}" --delete

echo "remaining VM machines in $VBOX_IMG_DIR:"
ls -al
cd -
echo "remaining vagrant boxes in the system:"
vagrant box list
echo "The VM $vagrant_name was sucessfully deleted"
