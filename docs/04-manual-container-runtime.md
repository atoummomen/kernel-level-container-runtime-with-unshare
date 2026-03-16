# Manual Container Runtime (Without Engine)

## Objective

This phase demonstrates how to manually create a container using raw Linux kernel primitives, without any runtime engine abstraction.

The container is created using:

- Linux namespaces
- mount isolation
- pivot_root
- manual network namespace configuration

This step validates that isolation works before building the runtime engine.

---

## Namespace Creation

The container is created using `unshare` with the following namespaces:

- PID namespace
- Network namespace
- Mount namespace
- UTS namespace
- IPC namespace

Example:

```
sudo unshare --fork --pid --net --mount --uts --ipc /bin/bash
```

Inside this shell, the process runs in isolated namespaces.

---

## Mount Namespace Isolation

Before switching root, mount propagation must be made private:

```
mount --make-rprivate /
```

This ensures mount changes inside the container do not propagate to the host.

---

## Preparing the New Root

Assuming the container root filesystem is located at:

```
instances/container1/rootfs/
```

Create a temporary mount point inside the rootfs:

```
mkdir -p instances/container1/rootfs/oldroot
```

Bind-mount the root filesystem onto itself:

```
mount --bind instances/container1/rootfs instances/container1/rootfs
```

---

## Switching Root with pivot_root

Change directory into the new root:

```
cd instances/container1/rootfs
```

Execute:

```
pivot_root . oldroot
```

After this:

- `/` becomes the container root
- The previous host root is mounted at `/oldroot`

---

## Cleaning Up Old Root

Unmount the old host root:

```
umount -l /oldroot
rmdir /oldroot
```

At this point, the container is fully detached from the host filesystem.

---

## Mounting Required Virtual Filesystems

To make the container functional, mount:

```
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp
```

This restores essential kernel interfaces inside the container.

---

## Verifying Isolation

Inside the container:

Check PID namespace:

```
ps aux
```

The process should appear as PID 1.

Check hostname isolation:

```
hostname container1
hostname
```

Check mount isolation:

```
mount | grep proc
```

The container should now behave as an isolated environment.

---

## Summary

At this stage:

- The container has its own PID namespace
- It has its own mount namespace
- The root filesystem has been switched
- Host root is no longer accessible
- Kernel virtual filesystems are mounted

This confirms that Linux kernel primitives alone are sufficient to build a functional container.

The next phase will automate this process inside a minimal runtime engine.
