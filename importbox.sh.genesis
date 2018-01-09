#!/bin/sh
# Copyright (C) 2017, Codethink, Ltd., Robert Marshall
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# check parameter
if [ $# -ne 2 ] ; then
	echo "Usage: $0 boxLocation boxNewName" >&2
	exit 1
fi
set -e
box=$1
importedBox=$2
vagrant box add $importedBox $box
mv -f Vagrantfile Vagrantfile-tmp
vagrant init $importedBox
mv Vagrantfile-tmp Vagrantfile
sed -i Vagrantfile -e 's/debian\/stretch64/'"$importedBox"'/'

# are any mods necessary?
set +e
vagrant up
echo The above should end with "==> default: KernelCI already configured remove ~/mybbb.dat to force configuration"
echo and a report that the ssh command responded with a non-zero exit status. This is expected!
echo
echo new KernelCI board at desk ready for use
