# SF-FD-Spine-2

## Table of Contents

- [Management](#management)
  - [Agents](#agents)
  - [Management Interfaces](#management-interfaces)
  - [IP Name Servers](#ip-name-servers)
  - [Domain Lookup](#domain-lookup)
  - [NTP](#ntp)
  - [Management API HTTP](#management-api-http)
- [Authentication](#authentication)
  - [Local Users](#local-users)
  - [Enable Password](#enable-password)
  - [AAA Authorization](#aaa-authorization)
- [DHCP Server](#dhcp-server)
  - [DHCP Servers Summary](#dhcp-servers-summary)
  - [DHCP Server Configuration](#dhcp-server-configuration)
  - [DHCP Server Interfaces](#dhcp-server-interfaces)
- [Monitoring](#monitoring)
  - [TerminAttr Daemon](#terminattr-daemon)
- [MLAG](#mlag)
  - [MLAG Summary](#mlag-summary)
  - [MLAG Device Configuration](#mlag-device-configuration)
- [Spanning Tree](#spanning-tree)
  - [Spanning Tree Summary](#spanning-tree-summary)
  - [Spanning Tree Device Configuration](#spanning-tree-device-configuration)
- [Internal VLAN Allocation Policy](#internal-vlan-allocation-policy)
  - [Internal VLAN Allocation Policy Summary](#internal-vlan-allocation-policy-summary)
  - [Internal VLAN Allocation Policy Device Configuration](#internal-vlan-allocation-policy-device-configuration)
- [VLANs](#vlans)
  - [VLANs Summary](#vlans-summary)
  - [VLANs Device Configuration](#vlans-device-configuration)
- [Interfaces](#interfaces)
  - [Ethernet Interfaces](#ethernet-interfaces)
  - [Port-Channel Interfaces](#port-channel-interfaces)
  - [Loopback Interfaces](#loopback-interfaces)
  - [VLAN Interfaces](#vlan-interfaces)
  - [VXLAN Interface](#vxlan-interface)
- [Routing](#routing)
  - [Service Routing Protocols Model](#service-routing-protocols-model)
  - [Virtual Router MAC Address](#virtual-router-mac-address)
  - [IP Routing](#ip-routing)
  - [IPv6 Routing](#ipv6-routing)
  - [Static Routes](#static-routes)
  - [Router BGP](#router-bgp)
- [BFD](#bfd)
  - [Router BFD](#router-bfd)
- [Multicast](#multicast)
  - [IP IGMP Snooping](#ip-igmp-snooping)
- [Filters](#filters)
  - [Prefix-lists](#prefix-lists)
  - [Route-maps](#route-maps)
- [VRF Instances](#vrf-instances)
  - [VRF Instances Summary](#vrf-instances-summary)
  - [VRF Instances Device Configuration](#vrf-instances-device-configuration)
- [Virtual Source NAT](#virtual-source-nat)
  - [Virtual Source NAT Summary](#virtual-source-nat-summary)
  - [Virtual Source NAT Configuration](#virtual-source-nat-configuration)

## Management

### Agents

#### Agent KernelFib

##### Environment Variables

| Name | Value |
| ---- | ----- |
| KERNELFIB_PROGRAM_ALL_ECMP | 'true' |

#### Agents Device Configuration

```eos
!
agent KernelFib environment KERNELFIB_PROGRAM_ALL_ECMP='true'
```

### Management Interfaces

#### Management Interfaces Summary

##### IPv4

| Management Interface | Description | Type | VRF | IP Address | Gateway |
| -------------------- | ----------- | ---- | --- | ---------- | ------- |
| Management1 | OOB_MANAGEMENT | oob | MGMT | 10.0.15.5/24 | 10.0.15.1 |

##### IPv6

| Management Interface | Description | Type | VRF | IPv6 Address | IPv6 Gateway |
| -------------------- | ----------- | ---- | --- | ------------ | ------------ |
| Management1 | OOB_MANAGEMENT | oob | MGMT | - | - |

#### Management Interfaces Device Configuration

```eos
!
interface Management1
   description OOB_MANAGEMENT
   no shutdown
   vrf MGMT
   ip address 10.0.15.5/24
   no lldp receive
```

### IP Name Servers

#### IP Name Servers Summary

| Name Server | VRF | Priority |
| ----------- | --- | -------- |
| 169.254.169.254 | default | - |

#### IP Name Servers Device Configuration

```eos
ip name-server vrf default 169.254.169.254
```

### Domain Lookup

#### DNS Domain Lookup Summary

| Source interface | vrf |
| ---------------- | --- |
| Loopback0 | - |

#### DNS Domain Lookup Device Configuration

```eos
ip domain lookup source-interface Loopback0
```

### NTP

#### NTP Summary

##### NTP Local Interface

| Interface | VRF |
| --------- | --- |
| Loopback0 | default |

##### NTP Servers

| Server | VRF | Preferred | Burst | iBurst | Version | Min Poll | Max Poll | Local-interface | Key |
| ------ | --- | --------- | ----- | ------ | ------- | -------- | -------- | --------------- | --- |
| 204.17.205.24 | default | - | - | - | - | - | - | - | - |
| pool.ntp.org | default | True | - | - | - | - | - | - | - |

#### NTP Device Configuration

```eos
!
ntp local-interface Loopback0
ntp server 204.17.205.24
ntp server pool.ntp.org prefer
```

### Management API HTTP

#### Management API HTTP Summary

| HTTP | HTTPS | UNIX-Socket | Default Services |
| ---- | ----- | ----------- | ---------------- |
| False | True | - | - |

#### Management API VRF Access

| VRF Name | IPv4 ACL | IPv6 ACL |
| -------- | -------- | -------- |
| default | - | - |

#### Management API HTTP Device Configuration

```eos
!
management api http-commands
   protocol https
   no shutdown
   !
   vrf default
      no shutdown
```

## Authentication

### Local Users

#### Local Users Summary

| User | Privilege | Role | Disabled | Shell |
| ---- | --------- | ---- | -------- | ----- |
| cvpadmin | 15 | network-admin | False | - |

#### Local Users Device Configuration

```eos
!
username cvpadmin privilege 15 role network-admin secret sha512 <removed>
```

### Enable Password

Enable password has been disabled

### AAA Authorization

#### AAA Authorization Summary

| Type | User Stores |
| ---- | ----------- |
| Exec | local |

Authorization for configuration commands is disabled.

#### AAA Authorization Device Configuration

```eos
aaa authorization exec default local
!
```

## DHCP Server

### DHCP Servers Summary

| DHCP Server Enabled | VRF | IPv4 DNS Domain | IPv4 DNS Servers | IPv4 Bootfile | IPv4 Lease Time | IPv6 DNS Domain | IPv6 DNS Servers | IPv6 Bootfile | IPv6 Lease Time |
| ------------------- | --- | --------------- | ---------------- | ------------- | --------------- | --------------- | ---------------- | ------------- | --------------- |
| True | default | - | 169.254.169.254 | http://172.16.254.253/bootstrap.py | - | - | - | - | - |

#### VRF default DHCP Server

##### Subnets

| Subnet | Name | DNS Servers | Default Gateway | Lease Time | Ranges |
| ------ | ---- | ----------- | --------------- | ---------- | ------ |
| 10.250.15.2/31 | inband ztp for SF-FD-Leaf-1A-Ethernet52 | - | 10.250.15.2 | - | 10.250.15.3-10.250.15.3 |
| 10.250.15.6/31 | inband ztp for SF-FD-Leaf-1B-Ethernet52 | - | 10.250.15.6 | - | 10.250.15.7-10.250.15.7 |
| 10.250.15.10/31 | inband ztp for SF-FD-Leaf-2A-Ethernet98/1 | - | 10.250.15.10 | - | 10.250.15.11-10.250.15.11 |
| 10.250.15.14/31 | inband ztp for SF-FD-Leaf-3A-Ethernet52 | - | 10.250.15.14 | - | 10.250.15.15-10.250.15.15 |
| 10.250.15.18/31 | inband ztp for SF-FD-Leaf-3B-Ethernet52 | - | 10.250.15.18 | - | 10.250.15.19-10.250.15.19 |

##### IPv4 Vendor Options

| Vendor ID | Sub-option Code | Sub-option Type | Sub-option Data |
| --------- | ----------------| --------------- | --------------- |
| NTP | 42 | array ipv4-address | 204.17.205.24 |

### DHCP Server Configuration

```eos
!
dhcp server
   dns server ipv4 169.254.169.254
   tftp server file ipv4 http://172.16.254.253/bootstrap.py
   !
   subnet 10.250.15.2/31
      !
      range 10.250.15.3 10.250.15.3
      name inband ztp for SF-FD-Leaf-1A-Ethernet52
      default-gateway 10.250.15.2
   !
   subnet 10.250.15.6/31
      !
      range 10.250.15.7 10.250.15.7
      name inband ztp for SF-FD-Leaf-1B-Ethernet52
      default-gateway 10.250.15.6
   !
   subnet 10.250.15.10/31
      !
      range 10.250.15.11 10.250.15.11
      name inband ztp for SF-FD-Leaf-2A-Ethernet98/1
      default-gateway 10.250.15.10
   !
   subnet 10.250.15.14/31
      !
      range 10.250.15.15 10.250.15.15
      name inband ztp for SF-FD-Leaf-3A-Ethernet52
      default-gateway 10.250.15.14
   !
   subnet 10.250.15.18/31
      !
      range 10.250.15.19 10.250.15.19
      name inband ztp for SF-FD-Leaf-3B-Ethernet52
      default-gateway 10.250.15.18
   !
   vendor-option ipv4 NTP
      sub-option 42 type array ipv4-address data 204.17.205.24
```

### DHCP Server Interfaces

| Interface name | DHCP IPv4 | DHCP IPv6 |
| -------------- | --------- | --------- |
| Ethernet1 | True | - |
| Ethernet2 | True | - |
| Ethernet3 | True | - |
| Ethernet4 | True | - |
| Ethernet5 | True | - |

## Monitoring

### TerminAttr Daemon

#### TerminAttr Daemon Summary

| CV Compression | CloudVision Servers | VRF | Authentication | Smash Excludes | Ingest Exclude | Bypass AAA |
| -------------- | ------------------- | --- | -------------- | -------------- | -------------- | ---------- |
| gzip | apiserver.cv-staging.corp.arista.io:443 | default | token-secure,/tmp/cv-onboarding-token | ale,flexCounter,hardware,kni,pulse,strata | - | True |

#### TerminAttr Daemon Device Configuration

```eos
!
daemon TerminAttr
   exec /usr/bin/TerminAttr -cvaddr=apiserver.cv-staging.corp.arista.io:443 -cvauth=token-secure,/tmp/cv-onboarding-token -cvvrf=default -disableaaa -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -taillogs -cvsourceintf=Loopback0
   no shutdown
```

## MLAG

### MLAG Summary

| Domain-id | Local-interface | Peer-address | Peer-link |
| --------- | --------------- | ------------ | --------- |
| MLAG | Vlan4094 | 169.254.0.0 | Port-Channel491 |

Dual primary detection is disabled.

### MLAG Device Configuration

```eos
!
mlag configuration
   domain-id MLAG
   local-interface Vlan4094
   peer-address 169.254.0.0
   peer-link Port-Channel491
   reload-delay mlag 300
   reload-delay non-mlag 330
```

## Spanning Tree

### Spanning Tree Summary

STP mode: **mstp**

#### MSTP Instance and Priority

| Instance(s) | Priority |
| -------- | -------- |
| 0 | 4096 |

#### Global Spanning-Tree Settings

- Spanning Tree disabled for VLANs: **4093-4094**

### Spanning Tree Device Configuration

```eos
!
spanning-tree mode mstp
no spanning-tree vlan-id 4093-4094
spanning-tree mst 0 priority 4096
```

## Internal VLAN Allocation Policy

### Internal VLAN Allocation Policy Summary

| Policy Allocation | Range Beginning | Range Ending |
| ------------------| --------------- | ------------ |
| ascending | 1006 | 1199 |

### Internal VLAN Allocation Policy Device Configuration

```eos
!
vlan internal order ascending range 1006 1199
```

## VLANs

### VLANs Summary

| VLAN ID | Name | Trunk Groups |
| ------- | ---- | ------------ |
| 10 | DATA | - |
| 20 | VOICE | - |
| 30 | PRINTERS | - |
| 3009 | MLAG_L3_VRF_CORPORATE | MLAG |
| 4092 | L2_INBAND_MGMT | - |
| 4093 | MLAG_L3 | MLAG |
| 4094 | MLAG | MLAG |

### VLANs Device Configuration

```eos
!
vlan 10
   name DATA
!
vlan 20
   name VOICE
!
vlan 30
   name PRINTERS
!
vlan 3009
   name MLAG_L3_VRF_CORPORATE
   trunk group MLAG
!
vlan 4092
   name L2_INBAND_MGMT
!
vlan 4093
   name MLAG_L3
   trunk group MLAG
!
vlan 4094
   name MLAG
   trunk group MLAG
```

## Interfaces

### Ethernet Interfaces

#### Ethernet Interfaces Summary

##### L2

| Interface | Description | Mode | VLANs | Native VLAN | Trunk Group | Channel-Group |
| --------- | ----------- | ---- | ----- | ----------- | ----------- | ------------- |
| Ethernet49/1 | MLAG_SF-FD-Spine-1_Ethernet49/1 | *trunk | *- | *- | *MLAG | 491 |
| Ethernet50/1 | MLAG_SF-FD-Spine-1_Ethernet50/1 | *trunk | *- | *- | *MLAG | 491 |

*Inherited from Port-Channel Interface

##### IPv4

| Interface | Description | Channel Group | IP Address | VRF |  MTU | Shutdown | ACL In | ACL Out |
| --------- | ----------- | ------------- | ---------- | ----| ---- | -------- | ------ | ------- |
| Ethernet1 | P2P_SF-FD-Leaf-1A_Ethernet52 | - | 10.250.15.2/31 | default | 1500 | False | - | - |
| Ethernet2 | P2P_SF-FD-Leaf-1B_Ethernet52 | - | 10.250.15.6/31 | default | 1500 | False | - | - |
| Ethernet3 | P2P_SF-FD-Leaf-2A_Ethernet98/1 | - | 10.250.15.10/31 | default | 1500 | False | - | - |
| Ethernet4 | P2P_SF-FD-Leaf-3A_Ethernet52 | - | 10.250.15.14/31 | default | 1500 | False | - | - |
| Ethernet5 | P2P_SF-FD-Leaf-3B_Ethernet52 | - | 10.250.15.18/31 | default | 1500 | False | - | - |
| Ethernet51/1 | P2P_WAN-1_Ethernet16/1 | - | 10.255.0.31/31 | default | 1500 | False | - | - |

#### Ethernet Interfaces Device Configuration

```eos
!
interface Ethernet1
   description P2P_SF-FD-Leaf-1A_Ethernet52
   no shutdown
   mtu 1500
   no switchport
   ip address 10.250.15.2/31
   dhcp server ipv4
!
interface Ethernet2
   description P2P_SF-FD-Leaf-1B_Ethernet52
   no shutdown
   mtu 1500
   no switchport
   ip address 10.250.15.6/31
   dhcp server ipv4
!
interface Ethernet3
   description P2P_SF-FD-Leaf-2A_Ethernet98/1
   no shutdown
   mtu 1500
   no switchport
   ip address 10.250.15.10/31
   dhcp server ipv4
!
interface Ethernet4
   description P2P_SF-FD-Leaf-3A_Ethernet52
   no shutdown
   mtu 1500
   no switchport
   ip address 10.250.15.14/31
   dhcp server ipv4
!
interface Ethernet5
   description P2P_SF-FD-Leaf-3B_Ethernet52
   no shutdown
   mtu 1500
   no switchport
   ip address 10.250.15.18/31
   dhcp server ipv4
!
interface Ethernet49/1
   description MLAG_SF-FD-Spine-1_Ethernet49/1
   no shutdown
   channel-group 491 mode active
!
interface Ethernet50/1
   description MLAG_SF-FD-Spine-1_Ethernet50/1
   no shutdown
   channel-group 491 mode active
!
interface Ethernet51/1
   description P2P_WAN-1_Ethernet16/1
   no shutdown
   mtu 1500
   no switchport
   ip address 10.255.0.31/31
```

### Port-Channel Interfaces

#### Port-Channel Interfaces Summary

##### L2

| Interface | Description | Mode | VLANs | Native VLAN | Trunk Group | LACP Fallback Timeout | LACP Fallback Mode | MLAG ID | EVPN ESI |
| --------- | ----------- | ---- | ----- | ----------- | ------------| --------------------- | ------------------ | ------- | -------- |
| Port-Channel491 | MLAG_SF-FD-Spine-1_Port-Channel491 | trunk | - | - | MLAG | - | - | - | - |

#### Port-Channel Interfaces Device Configuration

```eos
!
interface Port-Channel491
   description MLAG_SF-FD-Spine-1_Port-Channel491
   no shutdown
   switchport mode trunk
   switchport trunk group MLAG
   switchport
```

### Loopback Interfaces

#### Loopback Interfaces Summary

##### IPv4

| Interface | Description | VRF | IP Address |
| --------- | ----------- | --- | ---------- |
| Loopback0 | ROUTER_ID | default | 10.255.255.162/32 |
| Loopback1 | VXLAN_TUNNEL_SOURCE | default | 10.255.254.161/32 |
| Loopback10 | DIAG_VRF_CORPORATE | CORPORATE | 10.255.255.162/32 |

##### IPv6

| Interface | Description | VRF | IPv6 Address |
| --------- | ----------- | --- | ------------ |
| Loopback0 | ROUTER_ID | default | - |
| Loopback1 | VXLAN_TUNNEL_SOURCE | default | - |
| Loopback10 | DIAG_VRF_CORPORATE | CORPORATE | - |

#### Loopback Interfaces Device Configuration

```eos
!
interface Loopback0
   description ROUTER_ID
   no shutdown
   ip address 10.255.255.162/32
!
interface Loopback1
   description VXLAN_TUNNEL_SOURCE
   no shutdown
   ip address 10.255.254.161/32
!
interface Loopback10
   description DIAG_VRF_CORPORATE
   no shutdown
   vrf CORPORATE
   ip address 10.255.255.162/32
```

### VLAN Interfaces

#### VLAN Interfaces Summary

| Interface | Description | VRF |  MTU | Shutdown |
| --------- | ----------- | --- | ---- | -------- |
| Vlan10 | DATA | CORPORATE | - | False |
| Vlan20 | VOICE | CORPORATE | - | False |
| Vlan30 | PRINTERS | CORPORATE | - | False |
| Vlan3009 | MLAG_L3_VRF_CORPORATE | CORPORATE | 1500 | False |
| Vlan4092 | L2_INBAND_MGMT | default | - | False |
| Vlan4093 | MLAG_L3 | default | 1500 | False |
| Vlan4094 | MLAG | default | 1500 | False |

##### IPv4

| Interface | VRF | IP Address | IP Address Virtual | IP Router Virtual Address | ACL In | ACL Out |
| --------- | --- | ---------- | ------------------ | ------------------------- | ------ | ------- |
| Vlan10 |  CORPORATE  |  -  |  10.15.10.1/24  |  -  |  -  |  -  |
| Vlan20 |  CORPORATE  |  -  |  10.15.20.1/24  |  -  |  -  |  -  |
| Vlan30 |  CORPORATE  |  -  |  10.15.30.1/24  |  -  |  -  |  -  |
| Vlan3009 |  CORPORATE  |  192.168.255.1/31  |  -  |  -  |  -  |  -  |
| Vlan4092 |  default  |  -  |  -  |  -  |  -  |  -  |
| Vlan4093 |  default  |  192.168.255.1/31  |  -  |  -  |  -  |  -  |
| Vlan4094 |  default  |  169.254.0.1/31  |  -  |  -  |  -  |  -  |

#### VLAN Interfaces Device Configuration

```eos
!
interface Vlan10
   description DATA
   no shutdown
   vrf CORPORATE
   ip address virtual 10.15.10.1/24
!
interface Vlan20
   description VOICE
   no shutdown
   vrf CORPORATE
   ip address virtual 10.15.20.1/24
!
interface Vlan30
   description PRINTERS
   no shutdown
   vrf CORPORATE
   ip address virtual 10.15.30.1/24
!
interface Vlan3009
   description MLAG_L3_VRF_CORPORATE
   no shutdown
   mtu 1500
   vrf CORPORATE
   ip address 192.168.255.1/31
!
interface Vlan4092
   description L2_INBAND_MGMT
   no shutdown
   ip helper-address 172.16.254.253
!
interface Vlan4093
   description MLAG_L3
   no shutdown
   mtu 1500
   ip address 192.168.255.1/31
!
interface Vlan4094
   description MLAG
   no shutdown
   mtu 1500
   no autostate
   ip address 169.254.0.1/31
```

### VXLAN Interface

#### VXLAN Interface Summary

| Setting | Value |
| ------- | ----- |
| Source Interface | Loopback1 |
| UDP port | 4789 |
| EVPN MLAG Shared Router MAC | mlag-system-id |

##### VLAN to VNI, Flood List and Multicast Group Mappings

| VLAN | VNI | Flood List | Multicast Group |
| ---- | --- | ---------- | --------------- |
| 10 | 10010 | - | - |
| 20 | 10020 | - | - |
| 30 | 10030 | - | - |
| 4092 | 14092 | - | - |

##### VRF to VNI and Multicast Group Mappings

| VRF | VNI | Overlay Multicast Group to Encap Mappings |
| --- | --- | ----------------------------------------- |
| CORPORATE | 10 | - |
| default | 1 | - |

#### VXLAN Interface Device Configuration

```eos
!
interface Vxlan1
   description SF-FD-Spine-2_VTEP
   vxlan source-interface Loopback1
   vxlan virtual-router encapsulation mac-address mlag-system-id
   vxlan udp-port 4789
   vxlan vlan 10 vni 10010
   vxlan vlan 20 vni 10020
   vxlan vlan 30 vni 10030
   vxlan vlan 4092 vni 14092
   vxlan vrf CORPORATE vni 10
   vxlan vrf default vni 1
```

## Routing

### Service Routing Protocols Model

Multi agent routing protocol model enabled

```eos
!
service routing protocols model multi-agent
```

### Virtual Router MAC Address

#### Virtual Router MAC Address Summary

Virtual Router MAC Address: 00:1c:73:00:00:99

#### Virtual Router MAC Address Device Configuration

```eos
!
ip virtual-router mac-address 00:1c:73:00:00:99
```

### IP Routing

#### IP Routing Summary

| VRF | Routing Enabled |
| --- | --------------- |
| default | True |
| CORPORATE | True |
| MGMT | False |

#### IP Routing Device Configuration

```eos
!
ip routing
ip routing vrf CORPORATE
no ip routing vrf MGMT
```

### IPv6 Routing

#### IPv6 Routing Summary

| VRF | Routing Enabled |
| --- | --------------- |
| default | False |
| CORPORATE | false |
| MGMT | false |

### Static Routes

#### Static Routes Summary

| VRF | Destination Prefix | Next Hop IP | Exit interface | Administrative Distance | Tag | Route Name | Metric |
| --- | ------------------ | ----------- | -------------- | ----------------------- | --- | ---------- | ------ |
| MGMT | 0.0.0.0/0 | 10.0.15.1 | - | 1 | - | - | - |

#### Static Routes Device Configuration

```eos
!
ip route vrf MGMT 0.0.0.0/0 10.0.15.1
```

### Router BGP

ASN Notation: asplain

#### Router BGP Summary

| BGP AS | Router ID |
| ------ | --------- |
| 65350 | 10.255.255.162 |

| BGP Tuning |
| ---------- |
| no bgp default ipv4-unicast |
| maximum-paths 4 ecmp 4 |

#### Router BGP Peer Groups

##### EVPN-OVERLAY-PEERS

| Settings | Value |
| -------- | ----- |
| Address Family | evpn |
| Next-hop unchanged | True |
| Source | Loopback0 |
| BFD | True |
| Ebgp multihop | 3 |
| Send community | all |
| Maximum routes | 0 (no limit) |

##### IPv4-UNDERLAY-PEERS

| Settings | Value |
| -------- | ----- |
| Address Family | ipv4 |
| Send community | all |
| Maximum routes | 12000 |

##### MLAG-IPv4-UNDERLAY-PEER

| Settings | Value |
| -------- | ----- |
| Address Family | ipv4 |
| Remote AS | 65350 |
| Next-hop self | True |
| Send community | all |
| Maximum routes | 12000 |

#### BGP Neighbors

| Neighbor | Remote AS | VRF | Shutdown | Send-community | Maximum-routes | Allowas-in | BFD | RIB Pre-Policy Retain | Route-Reflector Client | Passive | TTL Max Hops |
| -------- | --------- | --- | -------- | -------------- | -------------- | ---------- | --- | --------------------- | ---------------------- | ------- | ------------ |
| 10.250.15.3 | 65351 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.250.15.7 | 65351 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.250.15.11 | 65352 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.250.15.15 | 65353 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.250.15.19 | 65353 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.255.0.30 | 64750 | default | - | Inherited from peer group IPv4-UNDERLAY-PEERS | Inherited from peer group IPv4-UNDERLAY-PEERS | - | - | - | - | - | - |
| 10.255.255.163 | 65351 | default | - | Inherited from peer group EVPN-OVERLAY-PEERS | Inherited from peer group EVPN-OVERLAY-PEERS | - | Inherited from peer group EVPN-OVERLAY-PEERS | - | - | - | - |
| 10.255.255.164 | 65351 | default | - | Inherited from peer group EVPN-OVERLAY-PEERS | Inherited from peer group EVPN-OVERLAY-PEERS | - | Inherited from peer group EVPN-OVERLAY-PEERS | - | - | - | - |
| 10.255.255.165 | 65352 | default | - | Inherited from peer group EVPN-OVERLAY-PEERS | Inherited from peer group EVPN-OVERLAY-PEERS | - | Inherited from peer group EVPN-OVERLAY-PEERS | - | - | - | - |
| 10.255.255.166 | 65353 | default | - | Inherited from peer group EVPN-OVERLAY-PEERS | Inherited from peer group EVPN-OVERLAY-PEERS | - | Inherited from peer group EVPN-OVERLAY-PEERS | - | - | - | - |
| 10.255.255.167 | 65353 | default | - | Inherited from peer group EVPN-OVERLAY-PEERS | Inherited from peer group EVPN-OVERLAY-PEERS | - | Inherited from peer group EVPN-OVERLAY-PEERS | - | - | - | - |
| 192.168.255.0 | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | default | - | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | - | - | - | - | - | - |
| 192.168.255.0 | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | CORPORATE | - | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | Inherited from peer group MLAG-IPv4-UNDERLAY-PEER | - | - | - | - | - | - |

#### Router BGP EVPN Address Family

##### EVPN Peer Groups

| Peer Group | Activate | Route-map In | Route-map Out | Peer-tag In | Peer-tag Out | Encapsulation | Next-hop-self Source Interface |
| ---------- | -------- | ------------ | ------------- | ----------- | ------------ | ------------- | ------------------------------ |
| EVPN-OVERLAY-PEERS | True | - | - | - | - | default | - |

#### Router BGP VLANs

| VLAN | Route-Distinguisher | Both Route-Target | Import Route Target | Export Route-Target | Redistribute |
| ---- | ------------------- | ----------------- | ------------------- | ------------------- | ------------ |
| 10 | 10.255.255.162:10010 | 10010:10010 | - | - | learned |
| 20 | 10.255.255.162:10020 | 10020:10020 | - | - | learned |
| 30 | 10.255.255.162:10030 | 10030:10030 | - | - | learned |
| 4092 | 10.255.255.162:14092 | 14092:14092 | - | - | learned |

#### Router BGP VRFs

| VRF | Route-Distinguisher | Redistribute | Graceful Restart |
| --- | ------------------- | ------------ | ---------------- |
| CORPORATE | 10.255.255.162:10 | connected | - |
| default | 10.255.255.162:1 | - | - |

#### Router BGP Device Configuration

```eos
!
router bgp 65350
   router-id 10.255.255.162
   no bgp default ipv4-unicast
   maximum-paths 4 ecmp 4
   neighbor EVPN-OVERLAY-PEERS peer group
   neighbor EVPN-OVERLAY-PEERS next-hop-unchanged
   neighbor EVPN-OVERLAY-PEERS update-source Loopback0
   neighbor EVPN-OVERLAY-PEERS bfd
   neighbor EVPN-OVERLAY-PEERS ebgp-multihop 3
   neighbor EVPN-OVERLAY-PEERS send-community
   neighbor EVPN-OVERLAY-PEERS maximum-routes 0
   neighbor IPv4-UNDERLAY-PEERS peer group
   neighbor IPv4-UNDERLAY-PEERS send-community
   neighbor IPv4-UNDERLAY-PEERS maximum-routes 12000
   neighbor MLAG-IPv4-UNDERLAY-PEER peer group
   neighbor MLAG-IPv4-UNDERLAY-PEER remote-as 65350
   neighbor MLAG-IPv4-UNDERLAY-PEER next-hop-self
   neighbor MLAG-IPv4-UNDERLAY-PEER description SF-FD-Spine-1
   neighbor MLAG-IPv4-UNDERLAY-PEER route-map RM-MLAG-PEER-IN in
   neighbor MLAG-IPv4-UNDERLAY-PEER send-community
   neighbor MLAG-IPv4-UNDERLAY-PEER maximum-routes 12000
   neighbor 10.250.15.3 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.250.15.3 remote-as 65351
   neighbor 10.250.15.3 description SF-FD-Leaf-1A_Ethernet52
   neighbor 10.250.15.7 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.250.15.7 remote-as 65351
   neighbor 10.250.15.7 description SF-FD-Leaf-1B_Ethernet52
   neighbor 10.250.15.11 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.250.15.11 remote-as 65352
   neighbor 10.250.15.11 description SF-FD-Leaf-2A_Ethernet98/1
   neighbor 10.250.15.15 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.250.15.15 remote-as 65353
   neighbor 10.250.15.15 description SF-FD-Leaf-3A_Ethernet52
   neighbor 10.250.15.19 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.250.15.19 remote-as 65353
   neighbor 10.250.15.19 description SF-FD-Leaf-3B_Ethernet52
   neighbor 10.255.0.30 peer group IPv4-UNDERLAY-PEERS
   neighbor 10.255.0.30 remote-as 64750
   neighbor 10.255.0.30 description WAN-1
   neighbor 10.255.255.163 peer group EVPN-OVERLAY-PEERS
   neighbor 10.255.255.163 remote-as 65351
   neighbor 10.255.255.163 description SF-FD-Leaf-1A_Loopback0
   neighbor 10.255.255.164 peer group EVPN-OVERLAY-PEERS
   neighbor 10.255.255.164 remote-as 65351
   neighbor 10.255.255.164 description SF-FD-Leaf-1B_Loopback0
   neighbor 10.255.255.165 peer group EVPN-OVERLAY-PEERS
   neighbor 10.255.255.165 remote-as 65352
   neighbor 10.255.255.165 description SF-FD-Leaf-2A_Loopback0
   neighbor 10.255.255.166 peer group EVPN-OVERLAY-PEERS
   neighbor 10.255.255.166 remote-as 65353
   neighbor 10.255.255.166 description SF-FD-Leaf-3A_Loopback0
   neighbor 10.255.255.167 peer group EVPN-OVERLAY-PEERS
   neighbor 10.255.255.167 remote-as 65353
   neighbor 10.255.255.167 description SF-FD-Leaf-3B_Loopback0
   neighbor 192.168.255.0 peer group MLAG-IPv4-UNDERLAY-PEER
   neighbor 192.168.255.0 description SF-FD-Spine-1_Vlan4093
   redistribute connected route-map RM-CONN-2-BGP
   !
   vlan 10
      rd 10.255.255.162:10010
      route-target both 10010:10010
      redistribute learned
   !
   vlan 20
      rd 10.255.255.162:10020
      route-target both 10020:10020
      redistribute learned
   !
   vlan 30
      rd 10.255.255.162:10030
      route-target both 10030:10030
      redistribute learned
   !
   vlan 4092
      rd 10.255.255.162:14092
      route-target both 14092:14092
      redistribute learned
   !
   address-family evpn
      neighbor EVPN-OVERLAY-PEERS activate
   !
   address-family ipv4
      no neighbor EVPN-OVERLAY-PEERS activate
      neighbor IPv4-UNDERLAY-PEERS activate
      neighbor MLAG-IPv4-UNDERLAY-PEER activate
   !
   vrf CORPORATE
      rd 10.255.255.162:10
      route-target import evpn 10:10
      route-target export evpn 10:10
      router-id 10.255.255.162
      neighbor 192.168.255.0 peer group MLAG-IPv4-UNDERLAY-PEER
      neighbor 192.168.255.0 description SF-FD-Spine-1_Vlan3009
      redistribute connected route-map RM-CONN-2-BGP-VRFS
   !
   vrf default
      rd 10.255.255.162:1
      route-target import evpn 1:1
      route-target export evpn 1:1
```

## BFD

### Router BFD

#### Router BFD Multihop Summary

| Interval | Minimum RX | Multiplier |
| -------- | ---------- | ---------- |
| 300 | 300 | 3 |

#### Router BFD Device Configuration

```eos
!
router bfd
   multihop interval 300 min-rx 300 multiplier 3
```

## Multicast

### IP IGMP Snooping

#### IP IGMP Snooping Summary

| IGMP Snooping | Fast Leave | Interface Restart Query | Proxy | Restart Query Interval | Robustness Variable |
| ------------- | ---------- | ----------------------- | ----- | ---------------------- | ------------------- |
| Enabled | - | - | - | - | - |

#### IP IGMP Snooping Device Configuration

```eos
```

## Filters

### Prefix-lists

#### Prefix-lists Summary

##### PL-LOOPBACKS-EVPN-OVERLAY

| Sequence | Action |
| -------- | ------ |
| 10 | permit 10.255.255.160/28 eq 32 |
| 20 | permit 10.255.254.160/28 eq 32 |

##### PL-MLAG-PEER-VRFS

| Sequence | Action |
| -------- | ------ |
| 10 | permit 192.168.255.0/31 |

##### PL-P2P-LINKS

| Sequence | Action |
| -------- | ------ |
| 10 | permit 10.250.15.2/31 |
| 20 | permit 10.250.15.6/31 |
| 30 | permit 10.250.15.10/31 |
| 40 | permit 10.250.15.14/31 |
| 50 | permit 10.250.15.18/31 |

#### Prefix-lists Device Configuration

```eos
!
ip prefix-list PL-LOOPBACKS-EVPN-OVERLAY
   seq 10 permit 10.255.255.160/28 eq 32
   seq 20 permit 10.255.254.160/28 eq 32
!
ip prefix-list PL-MLAG-PEER-VRFS
   seq 10 permit 192.168.255.0/31
!
ip prefix-list PL-P2P-LINKS
   seq 10 permit 10.250.15.2/31
   seq 20 permit 10.250.15.6/31
   seq 30 permit 10.250.15.10/31
   seq 40 permit 10.250.15.14/31
   seq 50 permit 10.250.15.18/31
```

### Route-maps

#### Route-maps Summary

##### RM-CONN-2-BGP

| Sequence | Type | Match | Set | Sub-Route-Map | Continue |
| -------- | ---- | ----- | --- | ------------- | -------- |
| 10 | permit | ip address prefix-list PL-LOOPBACKS-EVPN-OVERLAY | - | - | - |
| 70 | permit | ip address prefix-list PL-P2P-LINKS | - | - | - |

##### RM-CONN-2-BGP-VRFS

| Sequence | Type | Match | Set | Sub-Route-Map | Continue |
| -------- | ---- | ----- | --- | ------------- | -------- |
| 10 | deny | ip address prefix-list PL-MLAG-PEER-VRFS | - | - | - |
| 20 | permit | - | - | - | - |

##### RM-MLAG-PEER-IN

| Sequence | Type | Match | Set | Sub-Route-Map | Continue |
| -------- | ---- | ----- | --- | ------------- | -------- |
| 10 | permit | - | origin incomplete | - | - |

#### Route-maps Device Configuration

```eos
!
route-map RM-CONN-2-BGP permit 10
   match ip address prefix-list PL-LOOPBACKS-EVPN-OVERLAY
!
route-map RM-CONN-2-BGP permit 70
   match ip address prefix-list PL-P2P-LINKS
!
route-map RM-CONN-2-BGP-VRFS deny 10
   match ip address prefix-list PL-MLAG-PEER-VRFS
!
route-map RM-CONN-2-BGP-VRFS permit 20
!
route-map RM-MLAG-PEER-IN permit 10
   description Make routes learned over MLAG Peer-link less preferred on spines to ensure optimal routing
   set origin incomplete
```

## VRF Instances

### VRF Instances Summary

| VRF Name | IP Routing |
| -------- | ---------- |
| CORPORATE | enabled |
| MGMT | disabled |

### VRF Instances Device Configuration

```eos
!
vrf instance CORPORATE
!
vrf instance MGMT
```

## Virtual Source NAT

### Virtual Source NAT Summary

| Source NAT VRF | Source NAT IPv4 Address | Source NAT IPv6 Address |
| -------------- | ----------------------- | ----------------------- |
| CORPORATE | 10.255.255.162 | - |

### Virtual Source NAT Configuration

```eos
!
ip address virtual source-nat vrf CORPORATE address 10.255.255.162
```
