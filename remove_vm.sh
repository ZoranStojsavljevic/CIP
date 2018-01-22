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

## Print out all the relevant data for the vagrant machine and underlying Virtual Box
## Find Virtual Box VM machine directory
VBOX_IMG_DIR=`vboxmanage list systemproperties | grep "Default machine folder" | cut -b 34-`
echo "Virtual Box VM machine directory: $VBOX_IMG_DIR"

if [ ! -d ".vagrant" ]; then
    echo "vagrant machine not created"
    exit 1
fi

## Find the UUID of the currently used Virtual Box machine
vbox_uuid=`cat .vagrant/machines/default/virtualbox/id`
echo "The UUID of the currently used Virtual Box machine $vbox_uuid"

## Find the UUID of the currently used vagrant machine
vagrant_uuid=`cat .vagrant/machines/default/virtualbox/index_uuid`
echo "The UUID of the currently used vagrant machine $vagrant_uuid"

echo "What vagrant machines are active in the system?"
vagrant box list

echo "What Virtual Box machines are active in the system?"
vboxmanage list vms

vagrant destroy $vagrant_uuid

exit 1

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

echo "$vm_id vm machine to be shutdown - brute force (?) shutdown"
VBoxManage controlvm "${vbox_uuid}" poweroff
sleep 2
echo "$vm_id vm machine to be removed"
vboxmanage unregistervm "${vbox_uuid}" --delete

echo "remaining VM machines in $VBOX_IMG_DIR:"
ls -al
cd -
echo "remaining vagrant boxes in the system:"
vagrant box list
echo "The VM $vagrant_name was sucessfully deleted"
