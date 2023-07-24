#!/bin/bash

#Firmadyne-deploy

#Dependencies
sudo apt-get install busybox-static fakeroot git dmsetup kpartx netcat-openbsd nmap python-psycopg2 python3-psycopg2 snmp uml-utilities util-linux vlan git unzip -y
sudo apt-get install qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils -y
sudo apt-get install mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsprogs cramfsswap squashfs-tools sleuthkit default-jdk lzop srecord
sudo -H pip install git+https://github.com/ahupp/python-magic

#python3
pip3 install python-magic

#ubifs
git clone https://github.com/nlitsme/ubidump.git
cd ubidump
pip install -r requirements.txt
pip install crcmod

git clone https://github.com/jrspruitt/ubi_reader
cd ubi_reader
sudo python setup.py install

#binwalk
cd /opt
git clone https://github.com/devttys0/binwalk.git
cd binwalk
sudo ./deps.sh --yes
sudo python3 ./setup.py install

#firmadyne
cd /opt
git clone --recursive https://github.com/firmadyne/firmadyne.git
cd firmadyne

#postgres

sudo apt-get install postgresql -y

#sudo -u postgres createuser -P firmadyne
sudo -u postgres bash -c "psql -c \"CREATE USER firmadyne WITH PASSWORD 'firmadyne';\""
sudo -u postgres createdb -O firmadyne firmware
sudo -u postgres psql -d firmware < ./database/schema

#firmadyne-binaries
./download.sh


docker run --privileged -it -v /Users/me/Desktop/autodyne/samples:/opt/firmadyne/samples -v /Users/me/Desktop/autodyne/samples-out:/opt/firmadyne/samples-out firmadyne /opt/firmadyne/autodyne-0.5a.sh
