# FD

## Table of Contents

- [Fabric Switches and Management IP](#fabric-switches-and-management-ip)
  - [Fabric Switches with inband Management IP](#fabric-switches-with-inband-management-ip)
- [Fabric Topology](#fabric-topology)
- [Fabric IP Allocation](#fabric-ip-allocation)
  - [Fabric Point-To-Point Links](#fabric-point-to-point-links)
  - [Point-To-Point Links Node Allocation](#point-to-point-links-node-allocation)
  - [Loopback Interfaces (BGP EVPN Peering)](#loopback-interfaces-bgp-evpn-peering)
  - [Loopback0 Interfaces Node Allocation](#loopback0-interfaces-node-allocation)
  - [VTEP Loopback VXLAN Tunnel Source Interfaces (VTEPs Only)](#vtep-loopback-vxlan-tunnel-source-interfaces-vteps-only)
  - [VTEP Loopback Node allocation](#vtep-loopback-node-allocation)

## Fabric Switches and Management IP

| POD | Type | Node | Management IP | Platform | Provisioned in CloudVision | Serial Number |
| --- | ---- | ---- | ------------- | -------- | -------------------------- | ------------- |
| FD | l3leaf | SF-FD-Leaf-1A | 10.0.15.6/24 | vEOS-lab | Provisioned | SN-SF-FD-Leaf-1A |
| FD | l3leaf | SF-FD-Leaf-1B | 10.0.15.7/24 | vEOS-lab | Provisioned | SN-SF-FD-Leaf-1B |
| FD | l3leaf | SF-FD-Leaf-2A | 10.0.15.8/24 | vEOS-lab | Provisioned | SN-SF-FD-Leaf-2A |
| FD | l3leaf | SF-FD-Leaf-3A | 10.0.15.9/24 | vEOS-lab | Provisioned | SN-SF-FD-Leaf-3A |
| FD | l3leaf | SF-FD-Leaf-3B | 10.0.15.10/24 | vEOS-lab | Provisioned | SN-SF-FD-Leaf-3B |
| FD | l2leaf | SF-FD-Leaf-3C | - | vEOS-lab | Provisioned | SN-SF-FD-Leaf-3C |
| FD | l2leaf | SF-FD-Leaf-3D | - | vEOS-lab | Provisioned | SN-SF-FD-Leaf-3D |
| FD | l2leaf | SF-FD-Leaf-3E | - | vEOS-lab | Provisioned | SN-SF-FD-Leaf-3E |
| FD | l3spine | SF-FD-Spine-1 | 10.0.15.4/24 | vEOS-lab | Provisioned | SN-SF-FD-Spine-1 |
| FD | l3spine | SF-FD-Spine-2 | 10.0.15.5/24 | vEOS-lab | Provisioned | SN-SF-FD-Spine-2 |

> Provision status is based on Ansible inventory declaration and do not represent real status from CloudVision.

### Fabric Switches with inband Management IP

| POD | Type | Node | Management IP | Inband Interface |
| --- | ---- | ---- | ------------- | ---------------- |
| FD | l2leaf | SF-FD-Leaf-3C | 10.1.15.100/27 | Vlan4092 |
| FD | l2leaf | SF-FD-Leaf-3D | 10.1.15.101/27 | Vlan4092 |
| FD | l2leaf | SF-FD-Leaf-3E | 10.1.15.102/27 | Vlan4092 |

## Fabric Topology

| Type | Node | Node Interface | Peer Type | Peer Node | Peer Interface |
| ---- | ---- | -------------- | --------- | ----------| -------------- |
| l3leaf | SF-FD-Leaf-1A | Ethernet49 | mlag_peer | SF-FD-Leaf-1B | Ethernet49 |
| l3leaf | SF-FD-Leaf-1A | Ethernet50 | mlag_peer | SF-FD-Leaf-1B | Ethernet50 |
| l3leaf | SF-FD-Leaf-1A | Ethernet51 | l3spine | SF-FD-Spine-1 | Ethernet1 |
| l3leaf | SF-FD-Leaf-1A | Ethernet52 | l3spine | SF-FD-Spine-2 | Ethernet1 |
| l3leaf | SF-FD-Leaf-1B | Ethernet51 | l3spine | SF-FD-Spine-1 | Ethernet2 |
| l3leaf | SF-FD-Leaf-1B | Ethernet52 | l3spine | SF-FD-Spine-2 | Ethernet2 |
| l3leaf | SF-FD-Leaf-2A | Ethernet97/1 | l3spine | SF-FD-Spine-1 | Ethernet3 |
| l3leaf | SF-FD-Leaf-2A | Ethernet98/1 | l3spine | SF-FD-Spine-2 | Ethernet3 |
| l3leaf | SF-FD-Leaf-3A | Ethernet49 | mlag_peer | SF-FD-Leaf-3B | Ethernet49 |
| l3leaf | SF-FD-Leaf-3A | Ethernet50 | mlag_peer | SF-FD-Leaf-3B | Ethernet50 |
| l3leaf | SF-FD-Leaf-3A | Ethernet51 | l3spine | SF-FD-Spine-1 | Ethernet4 |
| l3leaf | SF-FD-Leaf-3A | Ethernet52 | l3spine | SF-FD-Spine-2 | Ethernet4 |
| l3leaf | SF-FD-Leaf-3A | Ethernet53 | l2leaf | SF-FD-Leaf-3C | Ethernet25 |
| l3leaf | SF-FD-Leaf-3A | Ethernet54 | l2leaf | SF-FD-Leaf-3D | Ethernet25 |
| l3leaf | SF-FD-Leaf-3A | Ethernet55 | l2leaf | SF-FD-Leaf-3E | Ethernet25 |
| l3leaf | SF-FD-Leaf-3B | Ethernet51 | l3spine | SF-FD-Spine-1 | Ethernet5 |
| l3leaf | SF-FD-Leaf-3B | Ethernet52 | l3spine | SF-FD-Spine-2 | Ethernet5 |
| l3leaf | SF-FD-Leaf-3B | Ethernet53 | l2leaf | SF-FD-Leaf-3C | Ethernet26 |
| l3leaf | SF-FD-Leaf-3B | Ethernet54 | l2leaf | SF-FD-Leaf-3D | Ethernet26 |
| l3leaf | SF-FD-Leaf-3B | Ethernet55 | l2leaf | SF-FD-Leaf-3E | Ethernet26 |
| l2leaf | SF-FD-Leaf-3C | Ethernet27 | mlag_peer | SF-FD-Leaf-3D | Ethernet27 |
| l2leaf | SF-FD-Leaf-3C | Ethernet28 | mlag_peer | SF-FD-Leaf-3D | Ethernet28 |
| l3spine | SF-FD-Spine-1 | Ethernet49/1 | mlag_peer | SF-FD-Spine-2 | Ethernet49/1 |
| l3spine | SF-FD-Spine-1 | Ethernet50/1 | mlag_peer | SF-FD-Spine-2 | Ethernet50/1 |

## Fabric IP Allocation

### Fabric Point-To-Point Links

| Uplink IPv4 Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ---------------- | ------------------- | ------------------ | ------------------ |
| 10.250.15.0/24 | 256 | 20 | 7.82 % |

### Point-To-Point Links Node Allocation

| Node | Node Interface | Node IP Address | Peer Node | Peer Interface | Peer IP Address |
| ---- | -------------- | --------------- | --------- | -------------- | --------------- |
| SF-FD-Leaf-1A | Ethernet51 | 10.250.15.1/31 | SF-FD-Spine-1 | Ethernet1 | 10.250.15.0/31 |
| SF-FD-Leaf-1A | Ethernet52 | 10.250.15.3/31 | SF-FD-Spine-2 | Ethernet1 | 10.250.15.2/31 |
| SF-FD-Leaf-1B | Ethernet51 | 10.250.15.5/31 | SF-FD-Spine-1 | Ethernet2 | 10.250.15.4/31 |
| SF-FD-Leaf-1B | Ethernet52 | 10.250.15.7/31 | SF-FD-Spine-2 | Ethernet2 | 10.250.15.6/31 |
| SF-FD-Leaf-2A | Ethernet97/1 | 10.250.15.9/31 | SF-FD-Spine-1 | Ethernet3 | 10.250.15.8/31 |
| SF-FD-Leaf-2A | Ethernet98/1 | 10.250.15.11/31 | SF-FD-Spine-2 | Ethernet3 | 10.250.15.10/31 |
| SF-FD-Leaf-3A | Ethernet51 | 10.250.15.13/31 | SF-FD-Spine-1 | Ethernet4 | 10.250.15.12/31 |
| SF-FD-Leaf-3A | Ethernet52 | 10.250.15.15/31 | SF-FD-Spine-2 | Ethernet4 | 10.250.15.14/31 |
| SF-FD-Leaf-3B | Ethernet51 | 10.250.15.17/31 | SF-FD-Spine-1 | Ethernet5 | 10.250.15.16/31 |
| SF-FD-Leaf-3B | Ethernet52 | 10.250.15.19/31 | SF-FD-Spine-2 | Ethernet5 | 10.250.15.18/31 |

### Loopback Interfaces (BGP EVPN Peering)

| Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------- | ------------------- | ------------------ | ------------------ |
| 10.255.255.160/28 | 16 | 7 | 43.75 % |

### Loopback0 Interfaces Node Allocation

| POD | Node | Loopback0 |
| --- | ---- | --------- |
| FD | SF-FD-Leaf-1A | 10.255.255.163/32 |
| FD | SF-FD-Leaf-1B | 10.255.255.164/32 |
| FD | SF-FD-Leaf-2A | 10.255.255.165/32 |
| FD | SF-FD-Leaf-3A | 10.255.255.166/32 |
| FD | SF-FD-Leaf-3B | 10.255.255.167/32 |
| FD | SF-FD-Spine-1 | 10.255.255.161/32 |
| FD | SF-FD-Spine-2 | 10.255.255.162/32 |

### VTEP Loopback VXLAN Tunnel Source Interfaces (VTEPs Only)

| VTEP Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------------ | ------------------- | ------------------ | ------------------ |
| 10.255.254.160/28 | 16 | 5 | 31.25 % |

### VTEP Loopback Node allocation

| POD | Node | Loopback1 |
| --- | ---- | --------- |
| FD | SF-FD-Leaf-1A | 10.255.254.163/32 |
| FD | SF-FD-Leaf-1B | 10.255.254.163/32 |
| FD | SF-FD-Leaf-2A | 10.255.254.165/32 |
| FD | SF-FD-Leaf-3A | 10.255.254.166/32 |
| FD | SF-FD-Leaf-3B | 10.255.254.166/32 |
