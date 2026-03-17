#!/usr/bin/env bash

# Kernel-Level Container Runtime Lab Walkthrough
# This script documents the validated manual workflow.
# It is NOT intended to be executed blindly.
# Commands must be executed step-by-step in correct context.

###############################################################################
# STEP 1 — Create Container Instance Layout
###############################################################################

mkdir -p instances/container1/rootfs
mkdir -p instances/container1/root-mount
mkdir -p instances/container1/rootfs/oldroot

###############################################################################
# STEP 2 — Namespace Creation
###############################################################################

sudo unshare --fork --pid --net --mount --uts --ipc /bin/bash

###############################################################################
# STEP 3 — Inside Namespace (Manual Phase)
###############################################################################

mount --make-rprivate /
mount -t proc proc /proc

###############################################################################
# STEP 4 — Root Switching
###############################################################################

mount --bind rootfs rootfs
cd rootfs
pivot_root . oldroot
umount -l /oldroot
rmdir /oldroot

###############################################################################
# STEP 5 — Virtual Filesystems
###############################################################################

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp

###############################################################################
# STEP 6 — Container Networking (Host-Side)
###############################################################################

sudo ip link add br0 type bridge
sudo ip addr add 10.10.0.1/24 dev br0
sudo ip link set br0 up

sudo ip link add veth-host type veth peer name veth-cont
sudo ip link set veth-host master br0
sudo ip link set veth-host up

###############################################################################
# STEP 7 — NAT
###############################################################################

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
