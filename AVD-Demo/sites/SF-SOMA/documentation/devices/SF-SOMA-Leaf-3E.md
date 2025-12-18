# SF-SOMA-Leaf-3E

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
- [Monitoring](#monitoring)
  - [TerminAttr Daemon](#terminattr-daemon)
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
  - [VLAN Interfaces](#vlan-interfaces)
- [Routing](#routing)
  - [Service Routing Protocols Model](#service-routing-protocols-model)
  - [IP Routing](#ip-routing)
  - [IPv6 Routing](#ipv6-routing)
  - [Static Routes](#static-routes)
- [Multicast](#multicast)
  - [IP IGMP Snooping](#ip-igmp-snooping)
- [VRF Instances](#vrf-instances)
  - [VRF Instances Summary](#vrf-instances-summary)
  - [VRF Instances Device Configuration](#vrf-instances-device-configuration)

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
| Management1 | - | oob | default | - | - |

##### IPv6

| Management Interface | Description | Type | VRF | IPv6 Address | IPv6 Gateway |
| -------------------- | ----------- | ---- | --- | ------------ | ------------ |
| Management1 | - | oob | default | - | - |

#### Management Interfaces Device Configuration

```eos
!
interface Management1
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
| Vlan4092 | - |

#### DNS Domain Lookup Device Configuration

```eos
ip domain lookup source-interface Vlan4092
```

### NTP

#### NTP Summary

##### NTP Local Interface

| Interface | VRF |
| --------- | --- |
| Vlan4092 | default |

##### NTP Servers

| Server | VRF | Preferred | Burst | iBurst | Version | Min Poll | Max Poll | Local-interface | Key |
| ------ | --- | --------- | ----- | ------ | ------- | -------- | -------- | --------------- | --- |
| 204.17.205.24 | default | - | - | - | - | - | - | - | - |
| pool.ntp.org | default | True | - | - | - | - | - | - | - |

#### NTP Device Configuration

```eos
!
ntp local-interface Vlan4092
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
   exec /usr/bin/TerminAttr -cvaddr=apiserver.cv-staging.corp.arista.io:443 -cvauth=token-secure,/tmp/cv-onboarding-token -cvvrf=default -disableaaa -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -taillogs -cvsourceintf=Vlan4092
   no shutdown
```

## Spanning Tree

### Spanning Tree Summary

STP mode: **mstp**

#### MSTP Instance and Priority

| Instance(s) | Priority |
| -------- | -------- |
| 0 | 32768 |

### Spanning Tree Device Configuration

```eos
!
spanning-tree mode mstp
spanning-tree mst 0 priority 32768
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
| 4092 | INBAND_MGMT | - |

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
vlan 4092
   name INBAND_MGMT
```

## Interfaces

### Ethernet Interfaces

#### Ethernet Interfaces Summary

##### L2

| Interface | Description | Mode | VLANs | Native VLAN | Trunk Group | Channel-Group |
| --------- | ----------- | ---- | ----- | ----------- | ----------- | ------------- |
| Ethernet1 | - | access | 10 | - | - | - |
| Ethernet2 | - | access | 10 | - | - | - |
| Ethernet3 | - | access | 10 | - | - | - |
| Ethernet4 | - | access | 10 | - | - | - |
| Ethernet5 | - | access | 10 | - | - | - |
| Ethernet6 | - | access | 10 | - | - | - |
| Ethernet7 | - | access | 10 | - | - | - |
| Ethernet8 | - | access | 10 | - | - | - |
| Ethernet9 | - | access | 10 | - | - | - |
| Ethernet10 | - | access | 10 | - | - | - |
| Ethernet11 | - | access | 10 | - | - | - |
| Ethernet12 | - | access | 10 | - | - | - |
| Ethernet13 | - | access | 10 | - | - | - |
| Ethernet14 | - | access | 10 | - | - | - |
| Ethernet15 | - | access | 10 | - | - | - |
| Ethernet16 | - | access | 10 | - | - | - |
| Ethernet17 | - | access | 10 | - | - | - |
| Ethernet18 | - | access | 10 | - | - | - |
| Ethernet19 | - | access | 10 | - | - | - |
| Ethernet20 | - | access | 10 | - | - | - |
| Ethernet21 | - | access | 10 | - | - | - |
| Ethernet22 | - | access | 10 | - | - | - |
| Ethernet23 | - | access | 10 | - | - | - |
| Ethernet24 | - | access | 10 | - | - | - |
| Ethernet25 | - | *trunk | *10,20,30,4092 | *- | *- | 25 |
| Ethernet26 | - | *trunk | *10,20,30,4092 | *- | *- | 25 |
| Ethernet27 | - | access | 10 | - | - | - |
| Ethernet28 | - | access | 10 | - | - | - |
| Ethernet29 | - | access | 10 | - | - | - |
| Ethernet30 | - | access | 10 | - | - | - |
| Ethernet31 | - | access | 10 | - | - | - |

*Inherited from Port-Channel Interface

#### Ethernet Interfaces Device Configuration

```eos
!
interface Ethernet1
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet2
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet3
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet4
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet5
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet6
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet7
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet8
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet9
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet10
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet11
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet12
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet13
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet14
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet15
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet16
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet17
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet18
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet19
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet20
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet21
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet22
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet23
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet24
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet25
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   channel-group 25 mode active
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet26
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   channel-group 25 mode active
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet27
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet28
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet29
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet30
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
!
interface Ethernet31
   no shutdown
   switchport access vlan 10
   switchport mode access
   switchport
   spanning-tree portfast
   spanning-tree bpduguard enable
```

### Port-Channel Interfaces

#### Port-Channel Interfaces Summary

##### L2

| Interface | Description | Mode | VLANs | Native VLAN | Trunk Group | LACP Fallback Timeout | LACP Fallback Mode | MLAG ID | EVPN ESI |
| --------- | ----------- | ---- | ----- | ----------- | ------------| --------------------- | ------------------ | ------- | -------- |
| Port-Channel25 | L2_Floor3_Leafs_Port-Channel55 | trunk | 10,20,30,4092 | - | - | - | - | - | - |

#### Port-Channel Interfaces Device Configuration

```eos
!
interface Port-Channel25
   description L2_Floor3_Leafs_Port-Channel55
   no shutdown
   switchport trunk allowed vlan 10,20,30,4092
   switchport mode trunk
   switchport
```

### VLAN Interfaces

#### VLAN Interfaces Summary

| Interface | Description | VRF |  MTU | Shutdown |
| --------- | ----------- | --- | ---- | -------- |
| Vlan4092 | Inband Management | default | 1500 | False |

##### IPv4

| Interface | VRF | IP Address | IP Address Virtual | IP Router Virtual Address | ACL In | ACL Out |
| --------- | --- | ---------- | ------------------ | ------------------------- | ------ | ------- |
| Vlan4092 |  default  |  10.1.14.11/24  |  -  |  -  |  -  |  -  |

#### VLAN Interfaces Device Configuration

```eos
!
interface Vlan4092
   description Inband Management
   no shutdown
   mtu 1500
   ip address 10.1.14.11/24
```

## Routing

### Service Routing Protocols Model

Multi agent routing protocol model enabled

```eos
!
service routing protocols model multi-agent
```

### IP Routing

#### IP Routing Summary

| VRF | Routing Enabled |
| --- | --------------- |
| default | False |
| MGMT | False |

#### IP Routing Device Configuration

```eos
no ip routing vrf MGMT
```

### IPv6 Routing

#### IPv6 Routing Summary

| VRF | Routing Enabled |
| --- | --------------- |
| default | False |
| MGMT | false |

### Static Routes

#### Static Routes Summary

| VRF | Destination Prefix | Next Hop IP | Exit interface | Administrative Distance | Tag | Route Name | Metric |
| --- | ------------------ | ----------- | -------------- | ----------------------- | --- | ---------- | ------ |
| MGMT | 0.0.0.0/0 | 10.0.14.1 | - | 1 | - | - | - |
| default | 0.0.0.0/0 | 10.1.14.1 | - | 1 | - | - | - |

#### Static Routes Device Configuration

```eos
!
ip route 0.0.0.0/0 10.1.14.1
ip route vrf MGMT 0.0.0.0/0 10.0.14.1
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

## VRF Instances

### VRF Instances Summary

| VRF Name | IP Routing |
| -------- | ---------- |
| MGMT | disabled |

### VRF Instances Device Configuration

```eos
!
vrf instance MGMT
```
