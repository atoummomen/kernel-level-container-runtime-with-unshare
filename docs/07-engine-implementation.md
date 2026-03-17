# Runtime Engine Implementation

## Objective

This phase implements the minimal runtime engine that automates:

- Namespace creation
- Root filesystem switching
- Virtual filesystem mounting
- Networking setup
- Execution of the target process

The engine reproduces the previously validated manual steps in an automated and reusable form.

---

## Engine Entry Point

The engine is designed to be executed as:

```
./engine run <program> [arguments]
```

Example:

```
sudo ./engine run /bin/bash
sudo ./engine run /bin/echo "Hello from container"
```

The engine parses the `run` command and forwards the remaining arguments to the container process.

---

## Namespace Creation

The engine uses `unshare` to create isolated namespaces:

```
unshare --fork --pid --net --mount --uts --ipc --mount-proc
```

This ensures:

- A new PID namespace
- A new network namespace
- A new mount namespace
- A new UTS namespace
- A new IPC namespace

The container process is executed inside these namespaces.

---

## Mount Isolation

Inside the namespace:

```
mount --make-rprivate /
```

This prevents mount propagation back to the host.

---

## Root Filesystem Switching

The engine performs:

1. Bind mount rootfs onto itself  
2. Create temporary oldroot directory  
3. Execute pivot_root  
4. Unmount old root  

Example logic:

```
mount --bind rootfs rootfs
cd rootfs
mkdir -p oldroot
pivot_root . oldroot
umount -l /oldroot
rmdir /oldroot
```

After this step, the container is fully detached from the host root.

---

## Mounting Virtual Filesystems

The engine mounts required kernel interfaces:

```
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp
```

These mounts are necessary for a functional container environment.

---

## Networking Configuration

The engine:

- Creates a veth pair
- Attaches host side to br0
- Moves container side into namespace
- Assigns container IP
- Sets default route

Example container configuration:

```
ip link set lo up
ip link set veth-cont up
ip addr add 10.10.0.2/24 dev veth-cont
ip route add default via 10.10.0.1
```

Host NAT and forwarding must already be configured.

---

## Executing the Target Program

The final step inside the engine is:

```
exec "$@"
```

This replaces the engine process with the target program.

As a result:

- The program becomes PID 1
- Signal handling works correctly
- No wrapper process remains

This behavior is essential for correct container semantics.

---

## Implementation Scope

The engine is intentionally minimal.

It does not include:

- cgroups resource limitation
- Logging system
- Container lifecycle management
- Image registry support
- Multi-container orchestration

Its purpose is to demonstrate how a container runtime works internally using raw Linux primitives.

---

## Implementation Result

At this stage:

- Manual container creation is fully automated
- Namespace isolation is reproducible
- Networking integration is functional
- The runtime can execute arbitrary programs inside isolation

The system now behaves as a minimal, kernel-level container runtime.
