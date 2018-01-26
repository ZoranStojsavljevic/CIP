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

## This shell script is helper script, which shows dependencies between Vagrant and
## its most popular provider Virtual Box.

## Print out all the relevant data for the vagrant machine and underlying Virtual Box
## Find Virtual Box VM machine directory
VBOX_IMG_DIR=`vboxmanage list systemproperties | grep "Default machine folder" | cut -b 34-`
echo "Virtual Box VM machine directory: $VBOX_IMG_DIR"
echo ""

if [ ! -d ".vagrant" ]; then
    echo "vagrant machine not created"
    exit 1
fi

## Find the UUID of the currently used Virtual Box machine
vbox_uuid=`cat .vagrant/machines/default/virtualbox/id`
echo "The UUID of the currently used VBox    machine: $vbox_uuid"

## Find the UUID of the currently used vagrant machine
vagrant_uuid=`cat .vagrant/machines/default/virtualbox/index_uuid`
echo "The UUID of the currently used vagrant machine: $vagrant_uuid"
echo ""

echo "What vagrant machines are active in the system?"
vagrant box list
echo ""

echo "What Virtual Box machines are active in the system?"
vboxmanage list vms
echo""

echo "Check Global Status on the Vagrant environment of this machine"
echo "This data is cached and may not be completely up-to-date."
echo "Vagrant global status gives vagrant UUIDs, _NOT_ VBox ones!"
echo""
vagrant global-status
