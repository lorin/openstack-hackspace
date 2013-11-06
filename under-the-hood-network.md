# Under the hood: networking

The networking is the most complex aspect of OpenStack. When you are running
one virtual machine with a floating IP attached, your current DevStack
deployment should have networking that looks something like this:

![networking](network-under-hood.png)



Note that the exact name of the networking devices will vary, although the
prefixes (`tap`, `qbr`, `qvb`, `qvo`, `qr-`, `qg-`, `br`) will be the same.


You can list network interfaces by doing:

    $ ip a

Note that not all of them will appear, because of network namespaces.

## Network namespaces


OpenStack Networking uses network namespaces to isolate networks by providing
an isolated virtual networking stack. In particular, each network namespace
has its own:

 * network interfaces
 * routing table
 * iptables rules

To list the network namespaces, do:

    $ sudo ip netns list

The output should look something like this:

    qrouter-9e5f2802-2462-4f5c-a95b-c60b99744451
    qdhcp-4b523b2a-5921-4e8b-9e64-7b668c4aab85

As we'll see, you can also run an arbitrary commands inside of a network
namespace using `ip netns exec <namespace> <command>`.


## DHCP

The `qdhcp-` network namespace is where the DHCP server runs. OpenStack
uses dnsmasq for the networking.

There should be a `tap` device inside of the qdhcp- namespace. If you
execute the `ip a` command inside of the namespace, it will list all of the

    $ sudo ip netns exec qdhcp-4b523b2a-5921-4e8b-9e64-7b668c4aab85 ip a





## Routing

   $ sudo ip netns exec qrouter-9e5f2802-2462-4f5c-a95b-c60b99744451 route -n

## Floating IPs


## Security groups

You can see the rules that allow tcp connections destined for the ssh port
(port 22) and icmp inbound.


```
$ iptables -L neutron-openvswi-ib5e2060e-0
Chain neutron-openvswi-ib5e2060e-0 (1 references)
target     prot opt source               destination
DROP       all  --  anywhere             anywhere             state INVALID
RETURN     all  --  anywhere             anywhere             state RELATED,ESTABLISHED
RETURN     tcp  --  anywhere             anywhere             tcp dpt:ssh
RETURN     icmp --  anywhere             anywhere
RETURN     udp  --  10.0.0.2             anywhere             udp spt:bootps dpt:bootpc
neutron-openvswi-sg-fallback  all  --  anywhere             anywhere
```


List the ports on the internal bridge:

    # ovs-vsctl list-ports br-int
    qr-0d5ea29d-36
    qvob5e2060e-02
    tap1b197b45-16


List the ports on the external bridge:

    # ovs-vsctl list-ports br-ex
    qg-411a1cf8-f4



```
# ip netns list
qrouter-9e5f2802-2462-4f5c-a95b-c60b99744451
qdhcp-4b523b2a-5921-4e8b-9e64-7b668c4aab85
```


```
# ip netns exec qdhcp-4b523b2a-5921-4e8b-9e64-7b668c4aab85 ip a
9: tap1b197b45-16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:97:78:bd brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 brd 10.0.0.255 scope global tap1b197b45-16
    inet6 fe80::f816:3eff:fe97:78bd/64 scope link
       valid_lft forever preferred_lft forever
10: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
```

```
# ip netns exec qrouter-9e5f2802-2462-4f5c-a95b-c60b99744451 ip a
11: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
12: qr-0d5ea29d-36: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:dc:c5:47 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.1/24 brd 10.0.0.255 scope global qr-0d5ea29d-36
    inet6 fe80::f816:3eff:fedc:c547/64 scope link
       valid_lft forever preferred_lft forever
13: qg-411a1cf8-f4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether fa:16:3e:9c:fe:64 brd ff:ff:ff:ff:ff:ff
    inet 172.24.4.226/28 brd 172.24.4.239 scope global qg-411a1cf8-f4
    inet 172.24.4.227/32 brd 172.24.4.227 scope global qg-411a1cf8-f4
    inet6 fe80::f816:3eff:fe9c:fe64/64 scope link
       valid_lft forever preferred_lft forever
```


## DHCP

```
# ps ww `pgrep dnsmasq`
  PID TTY      STAT   TIME COMMAND
 1585 ?        S      0:00 dnsmasq --no-hosts --no-resolv --strict-order --bind-interfaces --interface=tap1b197b45-16 --except-interface=lo --pid-file=/opt/stack/data/neutron/dhcp/4b523b2a-5921-4e8b-9e64-7b668c4aab85/pid --dhcp-hostsfile=/opt/stack/data/neutron/dhcp/4b523b2a-5921-4e8b-9e64-7b668c4aab85/host --dhcp-optsfile=/opt/stack/data/neutron/dhcp/4b523b2a-5921-4e8b-9e64-7b668c4aab85/opts --leasefile-ro --dhcp-range=set:tag0,10.0.0.0,static,86400s --dhcp-lease-max=256 --conf-file= --domain=openstacklocal
```
