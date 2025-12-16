# DC

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
- [Connected Endpoints](#connected-endpoints)
  - [Port Profiles](#port-profiles)

## Fabric Switches and Management IP

| POD | Type | Node | Management IP | Platform | Provisioned in CloudVision | Serial Number |
| --- | ---- | ---- | ------------- | -------- | -------------------------- | ------------- |
| CH3_Pod1 | l3leaf | CH3-Border-Leaf-A | 10.0.2.27/24 | vEOS-lab | Provisioned | SN-CH3-Border-Leaf-A |
| CH3_Pod1 | l3leaf | CH3-Border-Leaf-B | 10.0.2.28/24 | vEOS-lab | Provisioned | SN-CH3-Border-Leaf-B |
| CH3_Pod1 | l3leaf | CH3-Leaf1A | 10.0.2.23/24 | vEOS-lab | Provisioned | SN-CH3-Leaf-1A |
| CH3_Pod1 | l3leaf | CH3-Leaf1B | 10.0.2.24/24 | vEOS-lab | Provisioned | SN-CH3-Leaf-1B |
| CH3_Pod1 | l3leaf | CH3-Leaf2A | 10.0.2.25/24 | vEOS-lab | Provisioned | SN-CH3-Leaf-2A |
| CH3_Pod1 | l3leaf | CH3-Leaf2B | 10.0.2.26/24 | vEOS-lab | Provisioned | SN-CH3-Leaf-2B |
| CH3_Pod1 | spine | CH3-Spine1 | 10.0.2.21/24 | vEOS-lab | Provisioned | SN-CH3-Spine-1 |
| CH3_Pod1 | spine | CH3-Spine2 | 10.0.2.22/24 | vEOS-lab | Provisioned | SN-CH3-Spine-2 |
| NY5_Pod1 | l3leaf | NY5-Border-Leaf-A | 10.0.1.17/24 | vEOS-lab | Provisioned | SN-NY5-Border-Leaf-A |
| NY5_Pod1 | l3leaf | NY5-Border-Leaf-B | 10.0.1.18/24 | vEOS-lab | Provisioned | SN-NY5-Border-Leaf-B |
| NY5_Pod1 | l3leaf | NY5-Leaf1A | 10.0.1.13/24 | vEOS-lab | Provisioned | SN-NY5-Leaf-1A |
| NY5_Pod1 | l3leaf | NY5-Leaf1B | 10.0.1.14/24 | vEOS-lab | Provisioned | SN-NY5-Leaf-1B |
| NY5_Pod1 | l3leaf | NY5-Leaf2A | 10.0.1.15/24 | vEOS-lab | Provisioned | SN-NY5-Leaf-2A |
| NY5_Pod1 | l3leaf | NY5-Leaf2B | 10.0.1.16/24 | vEOS-lab | Provisioned | SN-NY5-Leaf-2B |
| NY5_Pod1 | spine | NY5-Spine1 | 10.0.1.11/24 | vEOS-lab | Provisioned | SN-NY5-Spine-1 |
| NY5_Pod1 | spine | NY5-Spine2 | 10.0.1.12/24 | vEOS-lab | Provisioned | SN-NY5-Spine-2 |

> Provision status is based on Ansible inventory declaration and do not represent real status from CloudVision.

### Fabric Switches with inband Management IP

| POD | Type | Node | Management IP | Inband Interface |
| --- | ---- | ---- | ------------- | ---------------- |

## Fabric Topology

| Type | Node | Node Interface | Peer Type | Peer Node | Peer Interface |
| ---- | ---- | -------------- | --------- | ----------| -------------- |
| l3leaf | CH3-Border-Leaf-A | Ethernet53/1 | mlag_peer | CH3-Border-Leaf-B | Ethernet53/1 |
| l3leaf | CH3-Border-Leaf-A | Ethernet54/1 | mlag_peer | CH3-Border-Leaf-B | Ethernet54/1 |
| l3leaf | CH3-Border-Leaf-A | Ethernet55/1 | spine | CH3-Spine1 | Ethernet1/1 |
| l3leaf | CH3-Border-Leaf-A | Ethernet56/1 | spine | CH3-Spine2 | Ethernet1/1 |
| l3leaf | CH3-Border-Leaf-B | Ethernet55/1 | spine | CH3-Spine1 | Ethernet2/1 |
| l3leaf | CH3-Border-Leaf-B | Ethernet56/1 | spine | CH3-Spine2 | Ethernet2/1 |
| l3leaf | CH3-Leaf1A | Ethernet55/1 | spine | CH3-Spine1 | Ethernet3/1 |
| l3leaf | CH3-Leaf1A | Ethernet56/1 | spine | CH3-Spine2 | Ethernet3/1 |
| l3leaf | CH3-Leaf1B | Ethernet55/1 | spine | CH3-Spine1 | Ethernet4/1 |
| l3leaf | CH3-Leaf1B | Ethernet56/1 | spine | CH3-Spine2 | Ethernet4/1 |
| l3leaf | CH3-Leaf2A | Ethernet53/1 | mlag_peer | CH3-Leaf2B | Ethernet53/1 |
| l3leaf | CH3-Leaf2A | Ethernet54/1 | mlag_peer | CH3-Leaf2B | Ethernet54/1 |
| l3leaf | CH3-Leaf2A | Ethernet55/1 | spine | CH3-Spine1 | Ethernet5/1 |
| l3leaf | CH3-Leaf2A | Ethernet56/1 | spine | CH3-Spine2 | Ethernet5/1 |
| l3leaf | CH3-Leaf2B | Ethernet55/1 | spine | CH3-Spine1 | Ethernet6/1 |
| l3leaf | CH3-Leaf2B | Ethernet56/1 | spine | CH3-Spine2 | Ethernet6/1 |
| l3leaf | NY5-Border-Leaf-A | Ethernet49/1 | mlag_peer | NY5-Border-Leaf-B | Ethernet49/1 |
| l3leaf | NY5-Border-Leaf-A | Ethernet50/1 | mlag_peer | NY5-Border-Leaf-B | Ethernet50/1 |
| l3leaf | NY5-Border-Leaf-A | Ethernet51/1 | spine | NY5-Spine1 | Ethernet1/1 |
| l3leaf | NY5-Border-Leaf-A | Ethernet52/1 | spine | NY5-Spine2 | Ethernet1/1 |
| l3leaf | NY5-Border-Leaf-B | Ethernet51/1 | spine | NY5-Spine1 | Ethernet2/1 |
| l3leaf | NY5-Border-Leaf-B | Ethernet52/1 | spine | NY5-Spine2 | Ethernet2/1 |
| l3leaf | NY5-Leaf1A | Ethernet51/1 | spine | NY5-Spine1 | Ethernet3/1 |
| l3leaf | NY5-Leaf1A | Ethernet52/1 | spine | NY5-Spine2 | Ethernet3/1 |
| l3leaf | NY5-Leaf1B | Ethernet51/1 | spine | NY5-Spine1 | Ethernet4/1 |
| l3leaf | NY5-Leaf1B | Ethernet52/1 | spine | NY5-Spine2 | Ethernet4/1 |
| l3leaf | NY5-Leaf2A | Ethernet49/1 | mlag_peer | NY5-Leaf2B | Ethernet49/1 |
| l3leaf | NY5-Leaf2A | Ethernet50/1 | mlag_peer | NY5-Leaf2B | Ethernet50/1 |
| l3leaf | NY5-Leaf2A | Ethernet51/1 | spine | NY5-Spine1 | Ethernet5/1 |
| l3leaf | NY5-Leaf2A | Ethernet52/1 | spine | NY5-Spine2 | Ethernet5/1 |
| l3leaf | NY5-Leaf2B | Ethernet51/1 | spine | NY5-Spine1 | Ethernet6/1 |
| l3leaf | NY5-Leaf2B | Ethernet52/1 | spine | NY5-Spine2 | Ethernet6/1 |

## Fabric IP Allocation

### Fabric Point-To-Point Links

| Uplink IPv4 Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ---------------- | ------------------- | ------------------ | ------------------ |
| 192.168.11.0/26 | 64 | 22 | 34.38 % |
| 192.168.12.0/26 | 64 | 24 | 37.5 % |

### Point-To-Point Links Node Allocation

| Node | Node Interface | Node IP Address | Peer Node | Peer Interface | Peer IP Address |
| ---- | -------------- | --------------- | --------- | -------------- | --------------- |
| CH3-Border-Leaf-A | Ethernet55/1 | 192.168.12.1/31 | CH3-Spine1 | Ethernet1/1 | 192.168.12.0/31 |
| CH3-Border-Leaf-A | Ethernet56/1 | 192.168.12.3/31 | CH3-Spine2 | Ethernet1/1 | 192.168.12.2/31 |
| CH3-Border-Leaf-B | Ethernet55/1 | 192.168.12.5/31 | CH3-Spine1 | Ethernet2/1 | 192.168.12.4/31 |
| CH3-Border-Leaf-B | Ethernet56/1 | 192.168.12.7/31 | CH3-Spine2 | Ethernet2/1 | 192.168.12.6/31 |
| CH3-Leaf1A | Ethernet55/1 | 192.168.12.9/31 | CH3-Spine1 | Ethernet3/1 | 192.168.12.8/31 |
| CH3-Leaf1A | Ethernet56/1 | 192.168.12.11/31 | CH3-Spine2 | Ethernet3/1 | 192.168.12.10/31 |
| CH3-Leaf1B | Ethernet55/1 | 192.168.12.13/31 | CH3-Spine1 | Ethernet4/1 | 192.168.12.12/31 |
| CH3-Leaf1B | Ethernet56/1 | 192.168.12.15/31 | CH3-Spine2 | Ethernet4/1 | 192.168.12.14/31 |
| CH3-Leaf2A | Ethernet55/1 | 192.168.12.17/31 | CH3-Spine1 | Ethernet5/1 | 192.168.12.16/31 |
| CH3-Leaf2A | Ethernet56/1 | 192.168.12.19/31 | CH3-Spine2 | Ethernet5/1 | 192.168.12.18/31 |
| CH3-Leaf2B | Ethernet55/1 | 192.168.12.21/31 | CH3-Spine1 | Ethernet6/1 | 192.168.12.20/31 |
| CH3-Leaf2B | Ethernet56/1 | 192.168.12.23/31 | CH3-Spine2 | Ethernet6/1 | 192.168.12.22/31 |
| NY5-Border-Leaf-A | Ethernet51/1 | 192.168.11.1/31 | NY5-Spine1 | Ethernet1/1 | 192.168.11.0/31 |
| NY5-Border-Leaf-A | Ethernet52/1 | 10.255.0.1/31 | NY5-Spine2 | Ethernet1/1 | 192.168.11.2/31 |
| NY5-Border-Leaf-B | Ethernet51/1 | 192.168.11.5/31 | NY5-Spine1 | Ethernet2/1 | 192.168.11.4/31 |
| NY5-Border-Leaf-B | Ethernet52/1 | 10.255.0.3/31 | NY5-Spine2 | Ethernet2/1 | 192.168.11.6/31 |
| NY5-Leaf1A | Ethernet51/1 | 192.168.11.9/31 | NY5-Spine1 | Ethernet3/1 | 192.168.11.8/31 |
| NY5-Leaf1A | Ethernet52/1 | 192.168.11.11/31 | NY5-Spine2 | Ethernet3/1 | 192.168.11.10/31 |
| NY5-Leaf1B | Ethernet51/1 | 192.168.11.13/31 | NY5-Spine1 | Ethernet4/1 | 192.168.11.12/31 |
| NY5-Leaf1B | Ethernet52/1 | 192.168.11.15/31 | NY5-Spine2 | Ethernet4/1 | 192.168.11.14/31 |
| NY5-Leaf2A | Ethernet51/1 | 192.168.11.17/31 | NY5-Spine1 | Ethernet5/1 | 192.168.11.16/31 |
| NY5-Leaf2A | Ethernet52/1 | 192.168.11.19/31 | NY5-Spine2 | Ethernet5/1 | 192.168.11.18/31 |
| NY5-Leaf2B | Ethernet51/1 | 192.168.11.21/31 | NY5-Spine1 | Ethernet6/1 | 192.168.11.20/31 |
| NY5-Leaf2B | Ethernet52/1 | 192.168.11.23/31 | NY5-Spine2 | Ethernet6/1 | 192.168.11.22/31 |

### Loopback Interfaces (BGP EVPN Peering)

| Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------- | ------------------- | ------------------ | ------------------ |
| 10.245.217.0/27 | 32 | 8 | 25.0 % |
| 10.245.218.0/27 | 32 | 8 | 25.0 % |

### Loopback0 Interfaces Node Allocation

| POD | Node | Loopback0 |
| --- | ---- | --------- |
| CH3_Pod1 | CH3-Border-Leaf-A | 10.245.218.3/32 |
| CH3_Pod1 | CH3-Border-Leaf-B | 10.245.218.4/32 |
| CH3_Pod1 | CH3-Leaf1A | 10.245.218.5/32 |
| CH3_Pod1 | CH3-Leaf1B | 10.245.218.6/32 |
| CH3_Pod1 | CH3-Leaf2A | 10.245.218.7/32 |
| CH3_Pod1 | CH3-Leaf2B | 10.245.218.8/32 |
| CH3_Pod1 | CH3-Spine1 | 10.245.218.1/32 |
| CH3_Pod1 | CH3-Spine2 | 10.245.218.2/32 |
| NY5_Pod1 | NY5-Border-Leaf-A | 10.245.217.3/32 |
| NY5_Pod1 | NY5-Border-Leaf-B | 10.245.217.4/32 |
| NY5_Pod1 | NY5-Leaf1A | 10.245.217.5/32 |
| NY5_Pod1 | NY5-Leaf1B | 10.245.217.6/32 |
| NY5_Pod1 | NY5-Leaf2A | 10.245.217.7/32 |
| NY5_Pod1 | NY5-Leaf2B | 10.245.217.8/32 |
| NY5_Pod1 | NY5-Spine1 | 10.245.217.1/32 |
| NY5_Pod1 | NY5-Spine2 | 10.245.217.2/32 |

### VTEP Loopback VXLAN Tunnel Source Interfaces (VTEPs Only)

| VTEP Loopback Pool | Available Addresses | Assigned addresses | Assigned Address % |
| ------------------ | ------------------- | ------------------ | ------------------ |
| 10.245.217.32/27 | 32 | 6 | 18.75 % |
| 10.245.218.32/27 | 32 | 6 | 18.75 % |

### VTEP Loopback Node allocation

| POD | Node | Loopback1 |
| --- | ---- | --------- |
| CH3_Pod1 | CH3-Border-Leaf-A | 10.245.218.35/32 |
| CH3_Pod1 | CH3-Border-Leaf-B | 10.245.218.35/32 |
| CH3_Pod1 | CH3-Leaf1A | 10.245.218.37/32 |
| CH3_Pod1 | CH3-Leaf1B | 10.245.218.38/32 |
| CH3_Pod1 | CH3-Leaf2A | 10.245.218.39/32 |
| CH3_Pod1 | CH3-Leaf2B | 10.245.218.39/32 |
| NY5_Pod1 | NY5-Border-Leaf-A | 10.245.217.35/32 |
| NY5_Pod1 | NY5-Border-Leaf-B | 10.245.217.35/32 |
| NY5_Pod1 | NY5-Leaf1A | 10.245.217.37/32 |
| NY5_Pod1 | NY5-Leaf1B | 10.245.217.38/32 |
| NY5_Pod1 | NY5-Leaf2A | 10.245.217.39/32 |
| NY5_Pod1 | NY5-Leaf2B | 10.245.217.39/32 |

## Connected Endpoints

No connected endpoint configured!

### Port Profiles

| Profile Name | Parent Profile |
| ------------ | -------------- |
| Access | - |
