#!/bin/bash
# Copyright (C) 2018, Siemens AG, Zoran Stojsavljevic
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

echo "START: conf_private_net.sh"

## Configure network interfaces
## sudo copy ./interfaces /etc/network/interfaces
## sudo apt-get install ndiswrapper ndiswrapper-dkms ndiswrapper-source

## Put some additional useful packages into VM
## sudo apt-get install usbutils usbip-utils

##---------------------------------------------------------------

## #!/bin/bash

echo &quot;START test script: test.sh&quot;

## Check if there is a route to www/0.0.0.0, so the necessary setup could be performed
T_VAR=`ip route show | grep default | awk &apos;{print $1}&apos;`

echo &quot;default route installed? $T_VAR&quot;

if [ &quot;$T_VAR&quot; != &quot;default&quot; ]; then
	## More code to check eth0 i/f and specific VBox gw IP address must be added here
	ip route add default via 10.0.2.2 dev eth0
	sleep 1 ## wait for ip route add default to perform!
	T_VAR=`ip route show | grep default | awk &apos;{print $1}&apos;`
	if [ &quot;$T_VAR&quot; != &quot;default&quot; ]; then
		exit 127
	fi
fi

## Test along the execution
ip route show ## &gt; /dev/null

## Test eth2 interface, since this one (so far) is used as pass-through!

T_VAR=`ifconfig -a | grep &quot;eth2&quot; | awk &apos;{print $1}&apos; | sed &apos;s/://g&apos;`

if [ &quot;$T_VAR&quot; != &quot;eth2&quot; ]; then
	echo &quot;VMM USB/ETH passthrough mechanism failed!&quot;
	exit 127
fi

T_VAR=`ifconfig -a eth2 | grep &apos;inet &apos; | awk &apos;{print $2}&apos;`

if [ -z &quot;$T_VAR&quot; ]; then
	## give to eth2 the formal static address for DHCP init
	ifconfig eth2 192.168.15.2 up
fi

## Test along the execution
ifconfig eth2 ## &gt; /dev/null

## Configure and test power switch - egctl

T_VAR=`apt search egctl | grep installed | awk &apos;{print $4}&apos;`

## Test along the execution
echo &quot;egctl is installed? $T_VAR&quot;

if [ -z &quot;$T_VAR&quot; ]; then
        ## installation of egctl must be performed!
        apt-get install egctl
	cp ./egtab /etc/egtab
fi

## Test egctl (do we really need such a extensive testing)?
egctl egenie on on off off
sleep 1
egctl egenie on off on off
sleep 1
egctl egenie on off off on
sleep 1
egctl egenie on off off off

##-----------------------------------------

## Do we really need this?
## Configuring the static network!?

## Check upon systemd-networkd?

## $ systemctl restart systemd-networkd
## $ networkctl

## Processing tftpd server

T_VAR=`which in.tftpd`

## Test along the execution
echo &quot;tftpd installed? $T_VAR&quot;

if [ -z &quot;$T_VAR&quot; ]; then
        ## installation of tftpd-hpa must be performed!
        apt-get install tftpd-hpa
fi

## Does tftpd config file exist?
if [ -f /etc/default/tftpd-hpa ]; then
	T_VAR=`cat /etc/default/tftpd-hpa | grep &quot;0.0.0.0:69&quot; | sed &apos;s/&quot;/ /g&apos; | awk &apos;{print $2}&apos;`
	## Test along the execution
	if [ &quot;$T_VAR&quot; == &quot;0.0.0.0:69&quot; ]; then
		echo &quot;Listening on all network UDP ports? $T_VAR&quot;
	else
		cp ./tftpd-hpa /etc/default/tftpd-hpa
		echo &quot; Creating the politically correct tftpd-hpa config file&quot;
	fi
fi

## Does tftpd runs in the VM (should)?
T_VAR=`ps -e | grep in.tftpd | head -1 | awk &apos;{print $4}&apos;`
echo &quot;TFTPD process is: $T_VAR&quot;
if [ &quot;$T_VAR&quot; != &quot;in.tftpd&quot; ]; then
	echo &quot;Restarting in.tftpd server!&quot;
	/etc/init.d/tftpd-hpa restart
fi

## DHCPD service, running here as server

## netstat -lp | grep -i dhcpd ???

T_VAR=`apt search isc-dhcp-server | grep installed | awk &apos;{print $4}&apos;`

## Test along the execution
echo &quot;isc-dhcp-server installed? $T_VAR&quot;

if [ -z &quot;$T_VAR&quot; ]; then
        ## installation of egctl must be performed - for U-BOOT!
        apt-get install isc-dhcp-server
fi

## This must be done, since this is the 
cp ./dhcpd.conf /etc/dhcp/dhcpd.conf

if [ -f  /usr/lib/systemd/system/dhcpd.service ]; then
	cp /usr/lib/systemd/system/dhcpd.service /etc/systemd/system/dhcpd@.service
else
	echo &quot;the file /usr/lib/systemd/system/dhcpd.service was NOT found!&quot;
	echo &quot;Creating one from the local directory!&quot;
	cp ./dhcpd@.service /etc/systemd/system/dhcpd@.service
fi

## Check upon user and group dhcpd. Do they exist???
T_VAR=`cat /etc/passwd | grep dhcpd | sed &apos;s/:/ /g&apos; | awk &apos;{print $1}&apos;`

## Test along the execution
echo &quot; user dhcpd does exist? $T_VAR&quot;

if [ -z &quot;$T_VAR&quot; ]; then
	## create user: dhcpd and group dhcpd silently!
	adduser -system --no-create-home --disabled-login --disabled-password --shell /usr/sbin/nologin --gecos &quot;&quot; dhcpd
fi
