#!/bin/bash

start with some cleanup and installing new required packages
yum clean all
yum -y update
yum -y install httpd kea wget iptables-services tcpdump iftop

# next we'll run the script to pull all the boostrap files
cd ~
cat << EOF > workshop.py
#!python

import argparse
import requests
import json
import re
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


parser = argparse.ArgumentParser()
parser.add_argument('-staging_env', default=False, help='Generates bootstrap files for each tenant in the current directory', action='store_true')

args = parser.parse_args()

###########################################################################
### CVaaS Service AccountAPI Tokens
###########################################################################
apiToken = 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJkaWQiOjQyOTkzMzMxNjgsImRzbiI6IkFWRCIsImRzdCI6ImFjY291bnQiLCJleHAiOjE5MDkwMjIzOTksImlhdCI6MTc1MDY4ODQwMywib2dpIjo0Mjk5MjM3MTUyLCJvZ24iOiJqb2VyLWNhbXB1cyIsInNpZCI6ImY2NDczYjEyMWM3YWI5YzhkZTAyZGMzNzc1M2Y3YTQxOWY3YjY3OTA1NGFlOWZjOGUxZDhiN2QzYTVhODM4N2Itc3pHbGc2NjlIcmR5WWZMMDd4UmtzQTNaaGxrekpqR19hWjJGdmVRbSJ9.ZLHHoe6e1Vku9G5TmCUQ1TuEMN1yNpH7j3h-jcatUxVUU-thYNXh_NcJZUK6dVEh853hUwxyC5JZBvf4_WvrZw'

def genEnrollmentToken(tokenServer, authToken):
    url = f'https://{tokenServer}/api/v3/services/admin.Enrollment/AddEnrollmentToken'
    requestJson = {
            "enrollmentToken": {
                "reenrollDevices": ["*"],
                "validFor": "8760h"
            }
        }
    headers = {
            "Authorization": f"Bearer {authToken}"
        }

    resp = requests.post(url, data=json.dumps(requestJson), verify=False, timeout=20, headers=headers)
    resp.raise_for_status()

    result = resp.json()
    return result[0]["enrollmentToken"]["token"]

def genBootstrapFiles(apiToken):
    bootstrapURL = 'https://raw.githubusercontent.com/aristanetworks/cloudvision-ztpaas-utils/main/BootstrapScriptWithToken/bootstrap.py'
    resp = requests.get(bootstrapURL, verify=False, timeout=20)
    resp.raise_for_status()
    bootstrapFile = resp.text

    newAddr = "www.cv-staging.corp.arista.io"
    tokenServer = "www.cv-staging.corp.arista.io"
    newToken = genEnrollmentToken(tokenServer, apiToken)
    f2 = re.sub('cvAddr = ""', f'cvAddr = "{newAddr}"', bootstrapFile)
    f2 = re.sub('enrollmentToken = ""', f'enrollmentToken = "{newToken}"', f2)
    with open("bootstrap.py", "w") as newFile:
        newFile.write(f2)
        newFile.close()

def main():
    ###########################################################################
    ### generate tokens and bootstrap files for each environment
    ###########################################################################
    # i could add this to the loop below, but there is some special handling i
    #  want to do. slightly less efficient this way....
    genBootstrapFiles(apiToken)

if __name__ == "__main__":
    main()
EOF

cd /var/www/html
python3 ~/workshop.py

cat <<EOF > /etc/kea/kea-dhcp4.conf
{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": [ "et1"]
        },
        "control-socket": {
            "socket-type": "unix",
            "socket-name": "/tmp/kea4-ctrl-socket"
        },
        "lease-database": {
            "type": "memfile",
            "lfc-interval": 3600
        },
        "expired-leases-processing": {
            "reclaim-timer-wait-time": 10,
            "flush-reclaimed-timer-wait-time": 25,
            "hold-reclaimed-time": 3600,
            "max-reclaim-leases": 100,
            "max-reclaim-time": 250,
            "unwarned-reclaim-cycles": 5
        },
        "renew-timer": 900,
        "rebind-timer": 1800,
        "valid-lifetime": 3600,
        "option-data": [
            {
                "name": "domain-name-servers",
                "data": "1.1.1.1"
            },
            {
                "code": 15,
                "data": "arista.local"
            },
            {
                "name": "domain-search",
                "data": "arista.local"
            },
            {
                "name": "default-ip-ttl",
                "data": "0xf0"
            }
        ],
        "subnet4": [
            {"subnet": "10.0.1.0/24", "comment": "Data Center 1 - OOB Management", "pools": [{"pool": "10.0.1.200 - 10.0.1.254"}], "option-data": [{"name": "routers", "data": "10.0.1.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.2.0/24", "comment": "Data Center 2 - OOB Management", "pools": [{"pool": "10.0.2.200 - 10.0.2.254"}], "option-data": [{"name": "routers", "data": "10.0.2.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.3.0/24", "comment": "Data Center 3 - OOB Management", "pools": [{"pool": "10.0.3.200 - 10.0.3.254"}], "option-data": [{"name": "routers", "data": "10.0.3.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.11.0/24", "comment": "Campus 1 - OOB Management", "pools": [{"pool": "10.0.11.200 - 10.0.11.254"}], "option-data": [{"name": "routers", "data": "10.0.11.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.12.0/24", "comment": "Campus 2 - OOB Management", "pools": [{"pool": "10.0.12.200 - 10.0.12.254"}], "option-data": [{"name": "routers", "data": "10.0.12.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.13.0/24", "comment": "Campus 3 - OOB Management", "pools": [{"pool": "10.0.13.200 - 10.0.13.254"}], "option-data": [{"name": "routers", "data": "10.0.13.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.14.0/24", "comment": "Campus 4 - OOB Management", "pools": [{"pool": "10.0.14.200 - 10.0.14.254"}], "option-data": [{"name": "routers", "data": "10.0.14.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.0.15.0/24", "comment": "Campus 5 - OOB Management", "pools": [{"pool": "10.0.15.200 - 10.0.15.254"}], "option-data": [{"name": "routers", "data": "10.0.15.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.11.0/24", "comment": "Campus 1 - In-band Management", "pools": [{"pool": "10.1.11.200 - 10.1.11.254"}], "option-data": [{"name": "routers", "data": "10.1.11.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.12.96/27", "comment": "Campus 2 Access Pod 3 - In-band Management", "pools": [{"pool": "10.1.12.110 - 10.1.12.123"}], "option-data": [{"name": "routers", "data": "10.1.12.97"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.12.0/24", "comment": "Campus 2 - In-band Management", "pools": [{"pool": "10.1.12.200 - 10.1.12.254"}], "option-data": [{"name": "routers", "data": "10.1.12.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.13.96/27", "comment": "Campus 3 Access Pod 3 - In-band Management", "pools": [{"pool": "10.1.13.110 - 10.1.13.123"}], "option-data": [{"name": "routers", "data": "10.1.13.97"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.13.0/24", "comment": "Campus 3 - In-band Management", "pools": [{"pool": "10.1.13.200 - 10.1.13.254"}], "option-data": [{"name": "routers", "data": "10.1.13.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.14.0/24", "comment": "Campus 4 - In-band Management", "pools": [{"pool": "10.1.14.200 - 10.1.14.254"}], "option-data": [{"name": "routers", "data": "10.1.14.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.15.96/27", "comment": "Campus 5 Access Pod 3 - In-band Management", "pools": [{"pool": "10.1.15.110 - 10.1.15.123"}], "option-data": [{"name": "routers", "data": "10.1.15.97"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.15.0/24", "comment": "Campus 5 - In-band Management", "pools": [{"pool": "10.1.15.200 - 10.1.15.254"}], "option-data": [{"name": "routers", "data": "10.1.15.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.21.0/24", "comment": "Remote Site 1 - In-band Management", "pools": [{"pool": "10.1.21.200 - 10.1.21.254"}], "option-data": [{"name": "routers", "data": "10.1.21.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.1.22.0/24", "comment": "Remote Site 2 - In-band Management", "pools": [{"pool": "10.1.22.200 - 10.1.22.254"}], "option-data": [{"name": "routers", "data": "10.1.22.1"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.12/31", "comment": "Campus 1 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.13 - 10.255.0.13"}], "option-data": [{"name": "routers", "data": "10.255.0.12"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.3.22.0/29", "comment": "Remote Site 2 - Transit SVI", "pools": [{"pool": "10.3.22.4 - 10.3.22.5"}], "option-data": [{"name": "routers", "data": "10.3.22.6"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.14/31", "comment": "Campus 1 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.15 - 10.255.0.15"}], "option-data": [{"name": "routers", "data": "10.255.0.14"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.16/31", "comment": "Campus 2 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.17 - 10.255.0.17"}], "option-data": [{"name": "routers", "data": "10.255.0.16"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.18/31", "comment": "Campus 2 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.19 - 10.255.0.19"}], "option-data": [{"name": "routers", "data": "10.255.0.18"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.20/31", "comment": "Campus 3 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.21 - 10.255.0.21"}], "option-data": [{"name": "routers", "data": "10.255.0.20"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.22/31", "comment": "Campus 3 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.23 - 10.255.0.23"}], "option-data": [{"name": "routers", "data": "10.255.0.22"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.24/31", "comment": "Campus 4 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.25 - 10.255.0.25"}], "option-data": [{"name": "routers", "data": "10.255.0.24"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.26/31", "comment": "Campus 4 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.27 - 10.255.0.27"}], "option-data": [{"name": "routers", "data": "10.255.0.26"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.28/31", "comment": "Campus 5 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.29 - 10.255.0.29"}], "option-data": [{"name": "routers", "data": "10.255.0.28"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.30/31", "comment": "Campus 5 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.31 - 10.255.0.31"}], "option-data": [{"name": "routers", "data": "10.255.0.30"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.32/31", "comment": "Remote Site 1 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.33 - 10.255.0.33"}], "option-data": [{"name": "routers", "data": "10.255.0.32"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.34/31", "comment": "Remote Site 1 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.35 - 10.255.0.35"}], "option-data": [{"name": "routers", "data": "10.255.0.34"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.36/31", "comment": "Remote Site 2 - PE-CE Link Primary", "pools": [{"pool": "10.255.0.37 - 10.255.0.37"}], "option-data": [{"name": "routers", "data": "10.255.0.36"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.255.0.38/31", "comment": "Remote Site 2 - PE-CE Link Secondary", "pools": [{"pool": "10.255.0.39 - 10.255.0.39"}], "option-data": [{"name": "routers", "data": "10.255.0.38"}, {"name": "boot-file-name", "data": "http://172.16.254.253/bootstrap.py"}]},
            {"subnet": "10.100.0.0/24", "comment": "Data Centers - PROD VRF - App Servers", "pools": [{"pool": "10.100.0.100 - 10.100.0.200"}], "option-data": [{"name": "routers", "data": "10.100.0.1"}]},
            {"subnet": "10.100.10.0/24", "comment": "Data Centers - PROD VRF - Database Servers", "pools": [{"pool": "10.100.10.100 - 10.100.10.200"}], "option-data": [{"name": "routers", "data": "10.100.10.1"}]},
            {"subnet": "10.100.20.0/24", "comment": "Data Centers - PROD VRF - Web Front-End", "pools": [{"pool": "10.100.20.100 - 10.100.20.200"}], "option-data": [{"name": "routers", "data": "10.100.20.1"}]},
            {"subnet": "10.200.0.0/24", "comment": "Data Centers - DEV VRF - Dev Environment", "pools": [{"pool": "10.200.0.100 - 10.200.0.200"}], "option-data": [{"name": "routers", "data": "10.200.0.1"}]},
            {"subnet": "10.200.10.0/24", "comment": "Data Centers - DEV VRF - Test Environment", "pools": [{"pool": "10.200.10.100 - 10.200.10.200"}], "option-data": [{"name": "routers", "data": "10.200.10.1"}]},
            {"subnet": "10.11.10.0/24", "comment": "Campus 1 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.11.10.100 - 10.11.10.200"}], "option-data": [{"name": "routers", "data": "10.11.10.1"}]},
            {"subnet": "10.11.20.0/24", "comment": "Campus 1 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.11.20.100 - 10.11.20.200"}], "option-data": [{"name": "routers", "data": "10.11.20.1"}]},
            {"subnet": "10.11.30.0/24", "comment": "Campus 1 - CORPORATE VRF - Printers", "pools": [{"pool": "10.11.30.100 - 10.11.30.200"}], "option-data": [{"name": "routers", "data": "10.11.30.1"}]},
            {"subnet": "10.11.40.0/24", "comment": "Campus 1 - CORPORATE VRF - Building Systems", "pools": [{"pool": "10.11.40.100 - 10.11.40.200"}], "option-data": [{"name": "routers", "data": "10.11.40.1"}]},
            {"subnet": "10.11.50.0/24", "comment": "Campus 1 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.11.50.100 - 10.11.50.200"}], "option-data": [{"name": "routers", "data": "10.11.50.1"}]},
            {"subnet": "10.12.10.32/27", "comment": "Campus 2 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.12.10.45 - 10.12.10.62"}], "option-data": [{"name": "routers", "data": "10.12.10.33"}]},
            {"subnet": "10.12.10.64/27", "comment": "Campus 2 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.12.10.75 - 10.12.10.94"}], "option-data": [{"name": "routers", "data": "10.12.10.65"}]},
            {"subnet": "10.12.10.96/27", "comment": "Campus 2 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.12.10.110 - 10.12.10.126"}], "option-data": [{"name": "routers", "data": "10.12.10.97"}]},
            {"subnet": "10.12.10.0/24", "comment": "Campus 2 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.12.10.200 - 10.12.10.254"}], "option-data": [{"name": "routers", "data": "10.12.10.1"}]},
            {"subnet": "10.12.20.32/27", "comment": "Campus 2 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.12.20.45 - 10.12.20.62"}], "option-data": [{"name": "routers", "data": "10.12.20.33"}]},
            {"subnet": "10.12.20.64/27", "comment": "Campus 2 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.12.20.75 - 10.12.20.94"}], "option-data": [{"name": "routers", "data": "10.12.20.65"}]},
            {"subnet": "10.12.20.96/27", "comment": "Campus 2 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.12.20.110 - 10.12.20.126"}], "option-data": [{"name": "routers", "data": "10.12.20.97"}]},
            {"subnet": "10.12.20.0/24", "comment": "Campus 2 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.12.20.100 - 10.12.20.200"}], "option-data": [{"name": "routers", "data": "10.12.20.1"}]},
            {"subnet": "10.12.30.32/27", "comment": "Campus 2 - CORPORATE VRF - Printers", "pools": [{"pool": "10.12.30.45 - 10.12.30.62"}], "option-data": [{"name": "routers", "data": "10.12.30.33"}]},
            {"subnet": "10.12.30.64/27", "comment": "Campus 2 - CORPORATE VRF - Printers", "pools": [{"pool": "10.12.30.75 - 10.12.30.94"}], "option-data": [{"name": "routers", "data": "10.12.30.65"}]},
            {"subnet": "10.12.30.96/27", "comment": "Campus 2 - CORPORATE VRF - Printers", "pools": [{"pool": "10.12.30.110 - 10.12.30.126"}], "option-data": [{"name": "routers", "data": "10.12.30.97"}]},
            {"subnet": "10.12.30.0/24", "comment": "Campus 2 - CORPORATE VRF - Printers", "pools": [{"pool": "10.12.30.100 - 10.12.30.200"}], "option-data": [{"name": "routers", "data": "10.12.30.1"}]},
            {"subnet": "10.12.40.0/24", "comment": "Campus 2 - CORPORATE VRF - Lab Equipment", "pools": [{"pool": "10.12.40.100 - 10.12.40.200"}], "option-data": [{"name": "routers", "data": "10.12.40.1"}]},
            {"subnet": "10.12.50.0/24", "comment": "Campus 2 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.12.50.100 - 10.12.50.200"}], "option-data": [{"name": "routers", "data": "10.12.50.1"}]},
            {"subnet": "10.13.10.0/24", "comment": "Campus 3 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.13.10.100 - 10.13.10.200"}], "option-data": [{"name": "routers", "data": "10.13.10.1"}]},
            {"subnet": "10.13.20.0/24", "comment": "Campus 3 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.13.20.100 - 10.13.20.200"}], "option-data": [{"name": "routers", "data": "10.13.20.1"}]},
            {"subnet": "10.13.30.0/24", "comment": "Campus 3 - CORPORATE VRF - Printers", "pools": [{"pool": "10.13.30.100 - 10.13.30.200"}], "option-data": [{"name": "routers", "data": "10.13.30.1"}]},
            {"subnet": "10.13.40.0/24", "comment": "Campus 3 - CORPORATE VRF - Building Automation", "pools": [{"pool": "10.13.40.100 - 10.13.40.200"}], "option-data": [{"name": "routers", "data": "10.13.40.1"}]},
            {"subnet": "10.13.50.0/24", "comment": "Campus 3 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.13.50.100 - 10.13.50.200"}], "option-data": [{"name": "routers", "data": "10.13.50.1"}]},
            {"subnet": "10.14.10.0/24", "comment": "Campus 4 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.14.10.100 - 10.14.10.200"}], "option-data": [{"name": "routers", "data": "10.14.10.1"}]},
            {"subnet": "10.14.20.0/24", "comment": "Campus 4 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.14.20.100 - 10.14.20.200"}], "option-data": [{"name": "routers", "data": "10.14.20.1"}]},
            {"subnet": "10.14.30.0/24", "comment": "Campus 4 - CORPORATE VRF - Printers", "pools": [{"pool": "10.14.30.100 - 10.14.30.200"}], "option-data": [{"name": "routers", "data": "10.14.30.1"}]},
            {"subnet": "10.14.40.0/24", "comment": "Campus 4 - CORPORATE VRF - AV Equipment", "pools": [{"pool": "10.14.40.100 - 10.14.40.200"}], "option-data": [{"name": "routers", "data": "10.14.40.1"}]},
            {"subnet": "10.14.50.0/24", "comment": "Campus 4 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.14.50.100 - 10.14.50.200"}], "option-data": [{"name": "routers", "data": "10.14.50.1"}]},
            {"subnet": "10.15.10.0/24", "comment": "Campus 5 - CORPORATE VRF - Staff Workstations", "pools": [{"pool": "10.15.10.100 - 10.15.10.200"}], "option-data": [{"name": "routers", "data": "10.15.10.1"}]},
            {"subnet": "10.15.20.0/24", "comment": "Campus 5 - CORPORATE VRF - Conference Rooms", "pools": [{"pool": "10.15.20.100 - 10.15.20.200"}], "option-data": [{"name": "routers", "data": "10.15.20.1"}]},
            {"subnet": "10.15.30.0/24", "comment": "Campus 5 - CORPORATE VRF - Printers", "pools": [{"pool": "10.15.30.100 - 10.15.30.200"}], "option-data": [{"name": "routers", "data": "10.15.30.1"}]},
            {"subnet": "10.15.40.0/24", "comment": "Campus 5 - CORPORATE VRF - Manufacturing Equipment", "pools": [{"pool": "10.15.40.100 - 10.15.40.200"}], "option-data": [{"name": "routers", "data": "10.15.40.1"}]},
            {"subnet": "10.15.50.0/24", "comment": "Campus 5 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.15.50.100 - 10.15.50.200"}], "option-data": [{"name": "routers", "data": "10.15.50.1"}]},
            {"subnet": "10.21.10.0/24", "comment": "Remote Site 1 - CORPORATE VRF - Workstations", "pools": [{"pool": "10.21.10.100 - 10.21.10.200"}], "option-data": [{"name": "routers", "data": "10.21.10.1"}]},
            {"subnet": "10.21.20.0/24", "comment": "Remote Site 1 - CORPORATE VRF - Printers", "pools": [{"pool": "10.21.20.100 - 10.21.20.200"}], "option-data": [{"name": "routers", "data": "10.21.20.1"}]},
            {"subnet": "10.21.30.0/24", "comment": "Remote Site 1 - CORPORATE VRF - VoIP Phones", "pools": [{"pool": "10.21.30.100 - 10.21.30.200"}], "option-data": [{"name": "routers", "data": "10.21.30.1"}]},
            {"subnet": "10.21.50.0/24", "comment": "Remote Site 1 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.21.50.100 - 10.21.50.200"}], "option-data": [{"name": "routers", "data": "10.21.50.1"}]},
            {"subnet": "10.22.10.0/24", "comment": "Remote Site 2 - CORPORATE VRF - Workstations", "pools": [{"pool": "10.22.10.100 - 10.22.10.200"}], "option-data": [{"name": "routers", "data": "10.22.10.1"}]},
            {"subnet": "10.22.20.0/24", "comment": "Remote Site 2 - CORPORATE VRF - Printers", "pools": [{"pool": "10.22.20.100 - 10.22.20.200"}], "option-data": [{"name": "routers", "data": "10.22.20.1"}]},
            {"subnet": "10.22.30.0/24", "comment": "Remote Site 2 - CORPORATE VRF - VoIP Phones", "pools": [{"pool": "10.22.30.100 - 10.22.30.200"}], "option-data": [{"name": "routers", "data": "10.22.30.1"}]},
            {"subnet": "10.22.50.0/24", "comment": "Remote Site 2 - GUEST VRF - Guest WiFi", "pools": [{"pool": "10.22.50.100 - 10.22.50.200"}], "option-data": [{"name": "routers", "data": "10.22.50.1"}]}
        ],
        "loggers": [
            {
                "name": "kea-dhcp4",
                "output_options": [
                    {
                        "output": "/var/log/kea-dhcp4.log"
                    }
                ],
                "severity": "INFO",
                "debuglevel": 0
            }
        ]
    }
}
EOF


cat << EOF > /etc/sysctl.d/98-forwarding.conf
net.ipv4.ip_forward = 1
EOF

systemctl disable firewalld
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/usr/libexec/iptables/iptables.init save

systemctl enable httpd kea-dhcp4 iptables

# For DHCP Leases, go to /var/lib/kea/kea-leases4.*

reboot
