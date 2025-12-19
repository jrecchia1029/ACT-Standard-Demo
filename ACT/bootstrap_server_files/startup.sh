# Set interfaces
# Avoid setting route for 10.18.128.1/32 as that is default route for node
sudo ip addr add 172.16.254.253/30 dev et1  # Connection to Router-1 Eth32
# Set routes for all internal networks
# sudo ip route add 10.0.0.0/8 via 172.16.254.254
# Covers 10.248.x.x through 10.255.x.x
# (which includes 10.250.x.x which is pe-ce and l3 underlays)
sudo ip route add 10.248.0.0/13 via 172.16.254.254
# PE-CE links
# sudo ip route add 10.255.0.0/24 via 172.16.254.254
# Underlay links, Loopbacks, Router IDs, VTEPs, 
# sudo ip route add 10.250.0.0/24 via 172.16.254.254
# Management Network Blocks (includes out-of-band and in-band mgmt)
sudo ip route add 10.0.0.0/14 via 172.16.254.254
# User/Service Subnets Campus 1: 
sudo ip route add 10.10.0.0/16 via 172.16.254.254
# User/Service Subnets Campus 2:
sudo ip route add 10.20.0.0/16 via 172.16.254.254
# User/Service Subnets Campus 3:
sudo ip route add 10.30.0.0/16 via 172.16.254.254
# User/Service Subnets Remote Site 1: 
sudo ip route add 10.61.0.0/16 via 172.16.254.254
# User/Service Subnets Remote Site 2:
sudo ip route add 10.62.0.0/16 via 172.16.254.254
# User/Service Data Center Prod VRF: 
sudo ip route add 10.100.0.0/16 via 172.16.254.254
# User/Service Data Center Dev VRF: 
sudo ip route add 10.200.0.0/16 via 172.16.254.254


# Start dhcp server
sudo systemctl restart kea-dhcp4
