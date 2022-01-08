ip link add mynet link eth0 type macvlan mode bridge
ip link add dockervlan link eth0 type macvlan mode bridge

d@nginx:~/dev$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:01:b6:27 brd ff:ff:ff:ff:ff:ff
    inet 10.55.254.126/24 brd 10.55.254.255 scope global dynamic eth0
       valid_lft 3303sec preferred_lft 3303sec
    inet6 fe80::215:5dff:fe01:b627/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:15:5d:01:b6:2b brd ff:ff:ff:ff:ff:ff
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:bf:f4:68:bd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:bfff:fef4:68bd/64 scope link 
       valid_lft forever preferred_lft forever
19: br-060832e29d64: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:b6:ab:68:ca brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-060832e29d64
       valid_lft forever preferred_lft forever
    inet6 fe80::42:b6ff:feab:68ca/64 scope link 
       valid_lft forever preferred_lft forever
23: vethdd9b61e@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-060832e29d64 state UP group default 
    link/ether da:54:8c:43:f7:33 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::d854:8cff:fe43:f733/64 scope link 
       valid_lft forever preferred_lft forever
d@nginx:~/dev$ sudo ip link add mynet link eth0 type macvlan mode bridge
[sudo] password for d: 
d@nginx:~/dev$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:01:b6:27 brd ff:ff:ff:ff:ff:ff
    inet 10.55.254.126/24 brd 10.55.254.255 scope global dynamic eth0
       valid_lft 3234sec preferred_lft 3234sec
    inet6 fe80::215:5dff:fe01:b627/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:15:5d:01:b6:2b brd ff:ff:ff:ff:ff:ff
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:bf:f4:68:bd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:bfff:fef4:68bd/64 scope link 
       valid_lft forever preferred_lft forever
19: br-060832e29d64: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:b6:ab:68:ca brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-060832e29d64
       valid_lft forever preferred_lft forever
    inet6 fe80::42:b6ff:feab:68ca/64 scope link 
       valid_lft forever preferred_lft forever
23: vethdd9b61e@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-060832e29d64 state UP group default 
    link/ether da:54:8c:43:f7:33 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::d854:8cff:fe43:f733/64 scope link 
       valid_lft forever preferred_lft forever
24: mynet@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 62:01:67:4e:9b:b0 brd ff:ff:ff:ff:ff:ff
d@nginx:~/dev$ 


sudo ip addr add 10.55.254.35/32 dev dockervlan

sudo ip route add 10.55.254.32/27 dev dockervlan
sudo ip link set dockervlan up

d@nginx:~/dev$ sudo ip link set mynet up
d@nginx:~/dev$ sudo ip route add 10.55.254.32/27 dev mynet
d@nginx:~/dev$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:01:b6:27 brd ff:ff:ff:ff:ff:ff
    inet 10.55.254.126/24 brd 10.55.254.255 scope global dynamic eth0
       valid_lft 3159sec preferred_lft 3159sec
    inet6 fe80::215:5dff:fe01:b627/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:15:5d:01:b6:2b brd ff:ff:ff:ff:ff:ff
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:bf:f4:68:bd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:bfff:fef4:68bd/64 scope link 
       valid_lft forever preferred_lft forever
19: br-060832e29d64: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:b6:ab:68:ca brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-060832e29d64
       valid_lft forever preferred_lft forever
    inet6 fe80::42:b6ff:feab:68ca/64 scope link 
       valid_lft forever preferred_lft forever
23: vethdd9b61e@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-060832e29d64 state UP group default 
    link/ether da:54:8c:43:f7:33 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::d854:8cff:fe43:f733/64 scope link 
       valid_lft forever preferred_lft forever
24: mynet@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 62:01:67:4e:9b:b0 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::6001:67ff:fe4e:9bb0/64 scope link 
       valid_lft forever preferred_lft forever
d@nginx:~/dev$ 



ip link add mynet link eth0 type macvlan mode bridge

sudo ip link add dockervlan link eth0 type macvlan mode bridge

sudo ip addr add 10.55.254.35/32 dev dockervlan
sudo ip link set dockervlan up

sudo ip route add 10.55.254.32/27 dev dockervlan


ip addr add 172.16.1.220/32 dev dockerrouteif
ip route add 172.16.1.224/27 dev dockerrouteif

