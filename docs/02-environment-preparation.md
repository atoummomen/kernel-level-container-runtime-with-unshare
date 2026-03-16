# Environment Preparation

## Host Platform

The container runtime was developed and validated on the following host platform:

- Distribution: Ubuntu 24.04.3 LTS (Noble Numbat)
- Kernel: 6.8.0-106-generic

This environment provides the Linux kernel features required to build a minimal container runtime directly from kernel primitives.

---

## Required Capabilities

The project depends on native Linux mechanisms for isolation, process execution, filesystem remapping, and networking.

The following kernel-level capabilities are required:

- Linux namespaces
- Mount isolation
- `pivot_root`
- Virtual Ethernet interfaces (`veth`)
- Linux bridge support
- IP forwarding
- NAT through `iptables`

These features are available in the selected Ubuntu host environment.

---

## Required User-Space Tools

The following tools were used during the lab:

- `unshare`  
  Used to create isolated namespaces for the container runtime.

- `ip`  
  Used for interface creation, addressing, routing, and namespace-aware networking.

- `iptables`  
  Used to enable NAT and outbound internet connectivity for the container.

- `mount`, `pivot_root`, `findmnt`  
  Used to build filesystem isolation and switch the container into its own root filesystem.

- `tree`  
  Used only for project structure inspection and validation.

- `wget` and `tar`  
  Used to download and extract the base Ubuntu root filesystem.

---

## Root Privileges

Several operations in this project require elevated privileges, including:

- namespace creation with networking isolation
- bridge creation
- veth attachment
- route manipulation
- NAT rule installation
- mount and `pivot_root` operations

For this reason, part of the workflow is executed with `sudo`.

---

## Networking Assumptions

The runtime uses a host-side bridge (`br0`) and a veth pair to connect the container to the host IP stack.

The validated networking model assumes:

- one container-side interface
- one host-side bridge
- host routing enabled
- outbound masquerading through the host uplink interface

This provides internet connectivity to the isolated container without requiring Docker, containerd, or orchestration components.

---

## Scope of This Preparation Phase

This phase prepares the host environment only.

It does not yet cover:

- root filesystem extraction
- manual container launch
- networking implementation details
- runtime engine execution

These are documented in the following sections of the project.
