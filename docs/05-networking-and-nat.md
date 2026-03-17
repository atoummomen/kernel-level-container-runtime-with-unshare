# Container Networking and NAT

## Objective

This phase connects the isolated container to the host network and enables outbound internet access.

The networking model is built manually using:

- veth pair
- Linux bridge
- IP forwarding
- NAT (MASQUERADE)

No Docker networking stack is used.

---

## Network Design Overview

The networking topology is:

Container (10.10.0.2)
    ↓
veth pair
    ↓
Linux bridge (br0 – 10.10.0.1)
    ↓
Host routing + NAT
    ↓
Host uplink interface (eth0)
    ↓
Internet

The container receives a private IP address and routes traffic through the host.

---

## Creating the Bridge

Create the bridge on the host:

```
sudo ip link add br0 type bridge
sudo ip addr add 10.10.0.1/24 dev br0
sudo ip link set br0 up
```

The bridge acts as the container gateway.

---

## Creating the veth Pair

Create a virtual Ethernet pair:

```
sudo ip link add veth-host type veth peer name veth-cont
```

- `veth-host` remains in the host namespace.
- `veth-cont` is moved into the container namespace.

Attach host side to bridge:

```
sudo ip link set veth-host master br0
sudo ip link set veth-host up
```

---

## Moving Interface to Container Namespace

Find the container PID:

```
ps aux | grep bash
```

Move interface:

```
sudo ip link set veth-cont netns <container-pid>
```

Inside the container namespace:

```
ip link set lo up
ip link set veth-cont up
ip addr add 10.10.0.2/24 dev veth-cont
ip route add default via 10.10.0.1
```

Now the container can reach the bridge gateway.

---

## Enabling IP Forwarding on Host

Enable forwarding:

```
sudo sysctl -w net.ipv4.ip_forward=1
```

To persist:

```
sudo nano /etc/sysctl.conf
```

Ensure:

```
net.ipv4.ip_forward=1
```

---

## Configuring NAT (MASQUERADE)

Allow outbound internet access:

```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Allow forwarding:

```
sudo iptables -A FORWARD -i br0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Now container traffic will be translated to the host IP when leaving via eth0.

---

## Testing Connectivity

Inside the container:

```
ping 10.10.0.1
ping 8.8.8.8
curl https://example.com
```

If successful:

- Bridge routing works
- NAT works
- Internet connectivity is functional

---

## Summary

At this stage:

- The container has an IP address (10.10.0.2)
- The host bridge acts as gateway (10.10.0.1)
- IP forwarding is enabled
- NAT translates container traffic
- The container can access external networks

This completes manual container networking.

The next step is integrating this logic into a minimal runtime engine.
