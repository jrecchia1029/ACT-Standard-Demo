# SOMA

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
| SOMA | l2leaf | SF-SOMA-Leaf-1A | 10.0.14.6/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-1A |
| SOMA | l2leaf | SF-SOMA-Leaf-1B | 10.0.14.7/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-1B |
| SOMA | l2leaf | SF-SOMA-Leaf-2A | 10.0.14.8/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-2A |
| SOMA | l2leaf | SF-SOMA-Leaf-3A | 10.0.14.9/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-3A |
| SOMA | l2leaf | SF-SOMA-Leaf-3B | 10.0.14.10/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-3B |
| SOMA | l2leaf | SF-SOMA-Leaf-3C | - | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-3C |
| SOMA | l2leaf | SF-SOMA-Leaf-3D | - | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-3D |
| SOMA | l2leaf | SF-SOMA-Leaf-3E | - | vEOS-lab | Provisioned | SN-SF-SOMA-Leaf-3E |
| SOMA | l3spine | SF-SOMA-Spine-1 | 10.0.14.4/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Spine-1 |
| SOMA | l3spine | SF-SOMA-Spine-2 | 10.0.14.5/24 | vEOS-lab | Provisioned | SN-SF-SOMA-Spine-2 |

> Provision status is based on Ansible inventory declaration and do not represent real status from CloudVision.

### Fabric Switches with inband Management IP

| POD | Type | Node | Management IP | Inband Interface |
| --- | ---- | ---- | ------------- | ---------------- |
| SOMA | l2leaf | SF-SOMA-Leaf-1A | 10.1.14.4/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-1B | 10.1.14.5/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-2A | 10.1.14.6/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-3A | 10.1.14.7/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-3B | 10.1.14.8/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-3C | 10.1.14.9/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-3D | 10.1.14.10/24 | Vlan4092 |
| SOMA | l2leaf | SF-SOMA-Leaf-3E | 10.1.14.11/24 | Vlan4092 |

## Fabric Topology

| Type | Node | Node Interface | Peer Type | Peer Node | Peer Interface |
| ---- | ---- | -------------- | --------- | ----------| -------------- |
| l2leaf | SF-SOMA-Leaf-1A | Ethernet49 | mlag_peer | SF-SOMA-Leaf-1B | Ethernet49 |
| l2leaf | SF-SOMA-Leaf-1A | Ethernet50 | mlag_peer | SF-SOMA-Leaf-1B | Ethernet50 |
| l2leaf | SF-SOMA-Leaf-1A | Ethernet51 | l3spine | SF-SOMA-Spine-1 | Ethernet1 |
| l2leaf | SF-SOMA-Leaf-1A | Ethernet52 | l3spine | SF-SOMA-Spine-2 | Ethernet1 |
| l2leaf | SF-SOMA-Leaf-1B | Ethernet51 | l3spine | SF-SOMA-Spine-1 | Ethernet2 |
| l2leaf | SF-SOMA-Leaf-1B | Ethernet52 | l3spine | SF-SOMA-Spine-2 | Ethernet2 |
| l2leaf | SF-SOMA-Leaf-2A | Ethernet97/1 | l3spine | SF-SOMA-Spine-1 | Ethernet3 |
| l2leaf | SF-SOMA-Leaf-2A | Ethernet98/1 | l3spine | SF-SOMA-Spine-2 | Ethernet3 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet49 | mlag_peer | SF-SOMA-Leaf-3B | Ethernet49 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet50 | mlag_peer | SF-SOMA-Leaf-3B | Ethernet50 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet51 | l3spine | SF-SOMA-Spine-1 | Ethernet4 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet52 | l3spine | SF-SOMA-Spine-2 | Ethernet4 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet53 | l2leaf | SF-SOMA-Leaf-3C | Ethernet25 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet54 | l2leaf | SF-SOMA-Leaf-3D | Ethernet25 |
| l2leaf | SF-SOMA-Leaf-3A | Ethernet55 | l2leaf | SF-SOMA-Leaf-3E | Ethernet25 |
| l2leaf | SF-SOMA-Leaf-3B | Ethernet51 | l3spine | SF-SOMA-Spine-1 | Ethernet5 |
| l2leaf | SF-SOMA-Leaf-3B | Ethernet52 | l3spine | SF-SOMA-Spine-2 | Ethernet5 |
| l2leaf | SF-SOMA-Leaf-3B | Ethernet53 | l2leaf | SF-SOMA-Leaf-3C | Ethernet26 |
| l2leaf | SF-SOMA-Leaf-3B | Ethernet54 | l2leaf | SF-SOMA-Leaf-3D | Ethernet26 |
| l2leaf | SF-SOMA-Leaf-3B | Ethernet55 | l2leaf | SF-SOMA-Leaf-3E | Ethernet26 |
| l3spine | SF-SOMA-Spine-1 | Ethernet49/1 | mlag_peer | SF-SOMA-Spine-2 | Ethernet49/1 |
| l3spine | SF-SOMA-Spine-1 | Ethernet50/1 | mlag_peer | SF-SOMA-Spine-2 | Ethernet50/1 |

## Fabric IP Allocation

### Fabric Point-To-Point Links

| Uplink IPv4 Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ---------------- | ------------------- | ------------------ | ------------------ |

### Point-To-Point Links Node Allocation

| Node | Node Interface | Node IP Address | Peer Node | Peer Interface | Peer IP Address |
| ---- | -------------- | --------------- | --------- | -------------- | --------------- |

### Loopback Interfaces (BGP EVPN Peering)

| Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------- | ------------------- | ------------------ | ------------------ |
| 10.255.255.144/28 | 16 | 2 | 12.5 % |

### Loopback0 Interfaces Node Allocation

| POD | Node | Loopback0 |
| --- | ---- | --------- |
| SOMA | SF-SOMA-Spine-1 | 10.255.255.145/32 |
| SOMA | SF-SOMA-Spine-2 | 10.255.255.146/32 |

### VTEP Loopback VXLAN Tunnel Source Interfaces (VTEPs Only)

| VTEP Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------------ | ------------------- | ------------------ | ------------------ |

### VTEP Loopback Node allocation

| POD | Node | Loopback1 |
| --- | ---- | --------- |
