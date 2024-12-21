#!/usr/bin/python -v
import argparse
import ipaddress as ip
# argv1 - netblock, start at 172.16.0.3
# argv2 - number of hosts to allocate addressing for

parser = argparse.ArgumentParser()
parser.add_argument('-b', dest='netblock', action='store', help='Netblock to start addressing from', required=True)
parser.add_argument('-n', dest='numhost', type=int, action='store', help='Number of hosts to add', required=True)
args = parser.parse_args()
Netblock = args.netblock
Numhost = args.numhost
compose_start ='''version: '3.5'

networks:
  autodyne:
    ipam:
      driver: default
      config:
        - subnet: 172.21.0.0/16
    name: autodyne

services:
  postgres:
    image: postgres
    container_name: autodyne-db
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=firmadyne
      - POSTGRES_PASSWORD=firmadyne
      - POSTGRES_DB=firmware
    networks:
      autodyne:
        ipv4_address: 172.21.0.2
        aliases:
          - postgres
          - autodyne-db
  
'''
compose_generate = '''  emulator-{{ counter }}:
    image: autodyne
    container_name: autodyne-em{{ counter }}
    depends_on:
      - postgres
      - autodyne
    privileged: true
    devices:
      - "/dev/mapper/control:/dev/mapper/control"
      - "/dev/loop-control:/dev/loop-control"
      - "/dev/loop0:/dev/loop0"
      - "/dev/loop1:/dev/loop1"
      - "/dev/loop2:/dev/loop2"
      - "/dev/loop3:/dev/loop3"
      - "/dev/loop4:/dev/loop4"
      - "/dev/loop5:/dev/loop5"
      - "/dev/loop6:/dev/loop6"
      - "/dev/loop7:/dev/loop7"
      - "/dev/loop8:/dev/loop8"
      - "/dev/loop9:/dev/loop9"
      - "/dev/loop10:/dev/loop10"
      - "/dev/loop11:/dev/loop11"
      - "/dev/loop12:/dev/loop12"
    command: [ "/opt/firmadyne/autodyne-0.5b.sh", "foo", "{{ sample }}"]
    volumes:
      - ./samples:/opt/firmadyne/samples
      - ./sample_output:/opt/firmadyne/samples-out
    networks:
      autodyne:
        ipv4_address: {{ ipcounter }}
        aliases:
          - autodyne-em{{ counter }}
'''
def generateIPranges(Netblock, Numhost):
    try:
        if not ip.ip_address(Netblock):
            print("Invalid ip address")
        print("Using %s as net block" % Netblock)

    except Exception as error:
        print("[-] script failed based on netblock; cause %s" % error)

    try:
        endblock = ip.ip_address(ip.ip_address(Netblock) + Numhost)
        print("Netblock ends on address %s" % str(endblock))
        #return (Netblock, endblock)

    except Exception as error:
        print("[-] script failed based on number of hosts; cause %s" % error)

    try:
        slash_notation = ip.summarize_address_range(ip.ip_address(Netblock), ip.ip_address(endblock))


    except Exception as error:
        print("[-] script failed based on slash notation; cause %s" % error)

# def generateComposeFile(Netblock, Numhost, samples):

generateIPranges(Netblock, Numhost)
