# Kernel-Level Container Runtime with unshare

## Overview

This project demonstrates how a minimal container runtime can be built directly on top of Linux kernel primitives without using Docker or any high-level container engine.

The goal is to understand, implement, and validate container isolation mechanisms manually using Linux namespaces, filesystem isolation, virtual networking, and NAT.

This project focuses on learning how containers actually work under the hood.

---

## What This Project Demonstrates

- Process isolation using Linux namespaces:
  - PID
  - NET
  - MNT
  - UTS
  - IPC

- Filesystem isolation using:
  - pivot_root
  - private mount propagation
  - /proc and /sys mounts

- Virtual networking:
  - veth pair
  - Linux bridge
  - Container IP configuration

- Internet access via:
  - Host routing
  - iptables NAT (MASQUERADE)

- Execution model:
  - Target process becomes PID 1 inside container
  - Runtime engine uses exec to replace itself

---

## Architecture Summary

The container runtime is executed on a Linux host (ccompute1).

Inside the host:

- A dedicated Linux bridge (br0) connects the container via a veth pair.
- The host performs routing and NAT to allow outbound internet connectivity.
- The container receives its own isolated network namespace and IP address.

Packet Flow:

Container → veth → br0 → Host IP stack → NAT → eth0 → Internet

---

## Repository Structure

architecture/ → Architecture diagrams (.drawio + .png)  
docs/ → Step-by-step technical documentation  
scripts/ → Engine implementation and lab walkthrough  
images/ → Screenshots and validation outputs  

Each documentation file follows the project evolution from manual namespace isolation to a minimal runtime engine.

---

## Lab Environment

- Linux host (Ubuntu-based)
- Manual namespace creation using unshare
- Networking via ip, bridge, and iptables
- No Docker, no containerd, no orchestration layer

---

## Purpose

This project is designed for deep technical understanding of container internals.

It is intended for:

- Cloud engineering learning
- Systems engineering practice
- Kernel-level isolation experimentation
- Portfolio demonstration of low-level container knowledge
