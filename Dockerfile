# docker build -t firmadyne .

FROM ubuntu:20.04

WORKDIR /opt
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo

#TZ
ADD tzset.sh /tmp
RUN chmod +x /tmp/tzset.sh
RUN /tmp/tzset.sh

ENV TZ=America/New_York


RUN sudo apt-get update && sudo apt-get -y upgrade
# Weird hijack to install cramfs on ubuntu 20....
RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/c/cramfs/cramfsprogs_1.1-6ubuntu1_amd64.deb -O /tmp/cramfsprogs_1.1-6ubuntu1_amd64.deb && sudo dpkg -i /tmp/cramfsprogs_1.1-6ubuntu1_amd64.deb

# python-psycopg2
RUN sudo apt-get build-dep pip install psycopg2-binary -y
RUN pip install psycopg2-binary
RUN sudo apt-get install busybox-static fakeroot git tmux dmsetup kpartx netcat-openbsd nmap python3-psycopg2 libmagic1 python-lzma python-lzo liblzo2-dev python-six snmp uml-utilities util-linux vlan git unzip curl wget nano postgresql-client socat -y
RUN sudo apt-get install qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils -y

# Weird hijack to install on ubuntu 20....

RUN sudo apt-get install mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsswap squashfs-tools sleuthkit default-jdk lzop srecord -y -m

# Adds for binwalk
RUN sudo apt install python3-distutils -y

# Python & pip
RUN sudo apt-get update && apt-get install -y \
        python \
    python-crcmod
RUN sudo curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o ./get-pip.py
RUN sudo python get-pip.py
RUN cd /opt
RUN sudo -H pip install git+https://github.com/ahupp/python-magic
RUN sudo -H pip install git+https://github.com/sviehb/jefferson

# Ubifs
RUN cd /opt
RUN sudo git clone --recursive https://github.com/nlitsme/ubidump.git
RUN pip install crcmod

RUN cd /opt
RUN sudo git clone --recursive https://github.com/jrspruitt/ubi_reader.git
RUN cd ubi_reader
RUN sudo pip install ubi_reader
WORKDIR /opt/ubi_reader
RUN chmod +x /opt/ubi_reader/setup.py
RUN sudo python /opt/ubi_reader/setup.py install

WORKDIR /opt

# Binwalk
RUN cd /opt
RUN sudo git clone --recursive https://github.com/ReFirmLabs/binwalk.git
RUN cd /opt/binwalk/
WORKDIR /opt/binwalk
RUN python setup.py install
RUN python3 setup.py install

# Clone Firmaadyne repo
WORKDIR /opt

RUN cd /opt
RUN git clone --recursive https://github.com/firmadyne/firmadyne.git

RUN mkdir -p /opt/firmadyne/samples/
RUN mkdir -p /opt/firmadyne/sample-out/

WORKDIR /opt/firmadyne
RUN /opt/firmadyne/download.sh
RUN sed -i '49 a USER=firmadyne' /opt/firmadyne/scripts/makeImage.sh
RUN sed -i '4 a FIRMWARE_DIR=/opt/firmadyne' /opt/firmadyne/firmadyne.config

# Postgres

RUN cd /opt

# Create firmadyne user
RUN useradd -m firmadyne
RUN echo "firmadyne:firmadyne" | chpasswd && adduser firmadyne sudo

USER root
COPY autodyne-0.5a.sh /opt/firmadyne
RUN chmod +x /opt/firmadyne/autodyne-0.5a.sh

COPY startup.sh /opt/firmadyne/startup.sh
RUN chmod +x /opt/firmadyne/startup.sh

COPY autodyne-cfg.sh /etc/autodyne-cfg.sh
RUN chmod +x /etc/autodyne-cfg.sh

RUN chown -R firmadyne:firmadyne /opt/firmadyne
RUN chown firmadyne:firmadyne /etc/autodyne-cfg.sh

#USER firmadyne

ENTRYPOINT ["/opt/firmadyne/startup.sh"]
CMD ["/bin/bash"]
