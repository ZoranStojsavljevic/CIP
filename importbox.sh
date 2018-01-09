#!/bin/bash
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

## Set markers for the RED color
RED='\e[1;31m'
NC='\e[0m' # No Color

## Start the vagrant assignment algorithm
if [ $# -ne 2 ] ; then
	echo "Usage: $0 boxNewName pathToBoxLocation"
	echo "Example: ./importbox.sh debian_stretch64 debian/stretch64"
	exit 1
fi
## set -e
boxNewName=$1
pathToBoxLocation=$2
echo -e "${RED}[1] Executing the command: vagrant box remove $boxNewName${NC}"
vagrant box remove $boxNewName
echo -e "${RED}[2] Executing the command: vagrant box list [to check which VMs remain]${NC}"
vagrant box list
echo -e "${RED}[3] Executing the command: vagrant box add $boxNewName $pathToBoxLocation${NC}"
vagrant box add $boxNewName $pathToBoxLocation
if [ -f Vagrantfile ]; then
    rm Vagrantfile
    ls -al
fi

echo -e "${RED}[4] Executing the command: vagrant init $boxNewName${NC}"
vagrant init $boxNewName
cp Vagrantfile.genesis Vagrantfile
## sed -i Vagrantfile -e 's/debian\/stretch64/'"$box"'/'
echo -e "${RED}[5] Executing the command: vagrant box list [to check if new VM is added]${NC}"
vagrant box list

# are any mods necessary?
## set +e
echo -e "${RED}[6] Executing the command: vagrant up --provider virtualbox${NC}"
vagrant up --provider virtualbox
echo The above should end with "==> default: KernelCI already configured remove ~/mybbb.dat to force configuration"
echo and a report that the ssh command responded with a non-zero exit status. This is expected!
echo
echo new KernelCI board at desk ready for use
