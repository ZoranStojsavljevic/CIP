#!/bin/sh
# Copyright (C) 2017, Codethink, Ltd., Robert Marshall
# Adopted file for Siemens AG CIP testing: Zoran Stojsavljevic
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# check number of parameters

## Set markers for the GREEN color
GREEN='\e[1;32m'
NC='\e[0m' # No Color

## Start the vagrant assignment algorithm
if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
    echo "Usage: $0 boxName (boxName => genericName)"
    echo "Usage: $0 boxName pathToBoxLocation"
    exit 1
fi
## set -e
boxName=$1
pathToBoxLocation=""
provider="which provider?"

if [ $# -eq 2 ] ; then
    pathToBoxLocation=$2
fi

echo -e "${GREEN}[1] Executing the command: vagrant box list [to check which VMs are in the pool]${NC}"
vagrant box list

echo -e "${GREEN}[2] Executing the command: vagrant box remove $boxName${NC}"
vagrant box remove $boxName

if [ $? -eq 0 ] ; then
    echo "Old box did exist, removed"
else
    echo "Old box did not exist"
fi

echo -e "${GREEN}[3] Executing the command: vagrant box list [to check which VMs remain]${NC}"
vagrant box list

echo -e "${GREEN}[4] Executing the command: vagrant box add $boxName $pathToBoxLocation${NC}"
vagrant box add $boxName $pathToBoxLocation
if [ -f Vagrantfile ]; then
    rm Vagrantfile ## rm old Vagrantfile, if any?
fi

echo -e "${GREEN}[5] Executing the command: vagrant init $boxName${NC}"
vagrant init $boxName
ls -al Vagrantfile

read -p "Do you want to overwrite Vagrantfile with already provided generic Vagrantfile? [Y/n] " qm

if [ -z $qm ] || [ $qm == 'Y' ] || [ $qm == 'y' ] ; then
    echo "Overwrite Vagrant file"
    cp Vagrantfile.genesis Vagrantfile
    sed -i -e 's\boxName\'"$boxName"'\' Vagrantfile
    ls -al Vagrantfile
else
    echo "Keep original Vagrantfile"
    ls -al Vagrantfile
fi

echo -e "${GREEN}[6] Executing the command: vagrant box list [to check if new VM is added]${NC}"
vagrant box list

# are any mods necessary?
set +e
echo -e "${GREEN}[7] Executing the command: vagrant up --provider $provider${NC}"
echo "==> Available vm providers:"
echo "1) libvirt"
echo "2) virtualbox"
read -p "==> Which vm provider should be used? " provider

case $provider in
[1])
    echo "The vm provider is libvirt"
    myprovider="libvirt"
    ;;

[2])
    echo "The vm provider is virtualbox"
    myprovider="virtualbox"
    ;;

*)
    echo "Did not give the correct vm provider!"
    ;;
esac

vagrant up --provider $myprovider
echo The above should end with "==> default: KernelCI already configured remove ~/mybbb.dat to force configuration"
echo and a report that the ssh command responded with a non-zero exit status. This is expected!
echo
echo new KernelCI board at desk ready for use
