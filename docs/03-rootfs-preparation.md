# Root Filesystem Preparation

## Objective

A container requires its own isolated root filesystem.

Instead of using Docker images or container registries, this project manually downloads and prepares a minimal Ubuntu root filesystem.

This allows full control over how the container environment is constructed.

---

## Base Image Selection

The root filesystem used in this project is:

- Ubuntu Jammy (22.04)
- Architecture: amd64
- Variant: default

The rootfs archive was obtained from the official Linux Containers image build system.

---

## Downloading the Root Filesystem

The root filesystem archive was downloaded using:

```bash
wget https://jenkins.linuxcontainers.org/job/image-ubuntu/architecture=amd64,release=jammy,variant=default/lastSuccessfulBuild/artifact/rootfs.tar.xz
```

This file contains a minimal Ubuntu filesystem layout including:

- /bin
- /lib
- /usr
- /etc
- /dev
- /proc (empty placeholder)
- /sys (empty placeholder)

---

## Project Directory Layout

The project separates images from container instances:

```
images/        → Base root filesystem archive and extracted image
instances/     → Runtime container instances
```

This separation ensures:

- The base image remains unchanged
- Instances can be recreated or deleted safely
- Multiple containers could be supported in future extensions

---

## Extracting the Root Filesystem

The archive is extracted into:

```
images/ubuntu-jammy-rootfs/
```

Using:

```bash
tar -xJf images/rootfs.tar.xz -C images/ubuntu-jammy-rootfs
```

After extraction, the directory contains a full minimal Linux filesystem tree.

---

## Creating a Container Instance

A dedicated instance directory is created:

```
instances/container1/
```

Inside it:

```
rootfs/        → Copy of the base filesystem
root-mount/    → Temporary mount target for pivot_root
```

The base image is copied into the instance rootfs:

```bash
cp -a images/ubuntu-jammy-rootfs/. instances/container1/rootfs/
```

This ensures each container instance has its own writable filesystem.


